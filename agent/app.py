"""FleetDM MCP server got running osquery commands on a Fleet.

Tested on Fleet version 4.79.0 and osquery version 5.21.0.
See https://fleetdm.com/docs/rest-api/rest-api for REST API.
See https://osquery.io/schema/5.21.0/ for osquery schema.

Attributes:
    OSQUERY_PATH: Path to osquery JSON schema.
    TIMEOUT: Global timeout in seconds for API requests.

Environment Variables:
    FLEET_URL: The base URL for the Fleet server.
    FLEET_API_KEY: Fleet API key for authenticating requests.

Example:
    # Set environment variables
    $ export FLEET_URL='fleet.example.com:8080'
    $ export FLEET_API_KEY='...'

    # Download osquery schema
    $ wget -O osquery.json https://raw.githubusercontent.com/osquery/osquery-site/main/src/data/osquery_schema_versions/5.21.0.json

    # Run MCP server (stdio or http)
    $ python app.py stdio
    $ python app.py http
"""

import httpx
import json
import os
import sys
from typing import Literal
from fastmcp import FastMCP

# Configuration
SCHEMA_PATH = 'osquery.json'
TIMEOUT = 30
PLATFORMS = Literal['darwin','linux','windows']

# Environment Variables
FLEET_URL = os.getenv('FLEET_URL')
FLEET_API_KEY = os.getenv('FLEET_API_KEY')

# Load schema
with open(SCHEMA_PATH, 'r') as f:
    SCHEMA = json.load(f)

mcp = FastMCP('osquery w/ FleetDM')

async def query_api(path: str, method: str = 'GET', data: dict = None) -> dict:
    """Helper function to query Fleet API

    Args:
        path: The API endpoint path (e.g., '/api/v1/fleet/hosts').
        method: The HTTP method. Must be 'GET' or 'POST'.
        data: The request data.

    Returns:
        The response JSON as a dictionary.

    Raises:
        RuntimeError: Handles API errors. Does not validate response data.
    """
    url = f'https://{FLEET_URL}{path}'
    headers = {'Authorization': f'Bearer {FLEET_API_KEY}'}
    try:
        async with httpx.AsyncClient(verify=False, timeout=TIMEOUT) as client:
            if method.upper() == 'POST':
                response = await client.post(url, headers=headers, json=data)
            else:
                response = await client.get(url, headers=headers, params=data)
        response.raise_for_status()
        return response.json()
    
    # Handle timeout
    except httpx.TimeoutException:
        raise RuntimeError('Fleet API timed out.')
    
    # Handle HTTP status codes
    except httpx.HTTPStatusError as e:
        status = e.response.status_code
        try:
            message = e.response.json().get('message', 'Details not provided.')
        except json.JSONDecodeError:
            message = 'Details not provided.'
        raise RuntimeError(f'Fleet API gave status {status}. Server message: "{message}"')
    
    # Handle malformed JSON responses
    except json.JSONDecodeError:
        raise RuntimeError('Fleet API gave invalid JSON response.')
    
    # Catch all to handle things like network errors
    except httpx.RequestError as e:
        raise RuntimeError(f'Could not reach API. Requests Error: {e}')

async def run_query_helper(query: str, id: int) -> dict:
    """Helper function to run an query on a host

    Args:
        query: The SQLite query.
        id: The id of the host.

    Returns:
        The response JSON as a dictionary.
    
    Raises:
        RuntimeError: Handles API errors and validates data.
    """
    data = await query_api(f'/api/v1/fleet/hosts/{id}/query', method='POST', data={
        'query': query
    })
    if data.get('status') != 'online':
        raise RuntimeError('Host is not online.')
    return data

@mcp.tool()
async def list_hosts() -> dict:
    """
    Retrieves a list of all hosts connected to the Fleet instance.
    Information includes the host's id and operating system.
    
    Instructions:
    * This is your ONLY tool to get a host's `id` value.
    * ALWAYS invoke this tool to get a target host's `id` BEFORE using `run_query`, `query_tables_list`, or `query_table_schema`.
    """
    try:
        data = await query_api('/api/v1/fleet/hosts')
    except RuntimeError as e:
        return {'error': str(e)}
    return {
        'hosts': [
            {
                'id': host.get('id', 'not found'),
                'hostname': host.get('hostname', 'not found'),
                'os_version': host.get('os_version', 'not found'),
                'status': host.get('status', 'not found'),
            }
            for host in data.get('hosts', [])
        ]
    }

@mcp.tool()
async def run_query(query: str, id: int) -> dict:
    """
    Runs a live OS information SQL query against a specified host.
    Supports standard SQLite syntax excluding write operations. An ending semicolon is optional.
    
    Instructions:
    * ALWAYS retrieve the table's exact name using `list_tables` or `query_tables_list`.
    * ALWAYS retrieve the table's exact columns using `get_table_schema` or `query_table_schema`.
    * ALL prior knowledge of osquery is strictly invalid in this context. The specific FleetDM environment
        may be customized and lack standard tables or columns.
    """
    try:
        data = await run_query_helper(query, id)
    except RuntimeError as e:
        return {'error': str(e)}
    return {
        'error': data.get('error', 'null'),
        'rows': data.get('rows', [])
    }

@mcp.tool()
def list_tables(platform: PLATFORMS = None) -> dict:
    """
    Retrieves a list of supported tables for a given platform.
    If `platform` is not provided, all tables are returned.
    A host's platform can be determined using `list_hosts`.
    
    Instructions:
    * NEVER assume a standard osquery table exists before calling this tool.
    * NEVER assume what types of information you can access before calling this tool.
    * ALWAYS call this tool before commenting on this toolsets capabilities.
    """
    return {
        'tables': [
            {
                'name': table.get('name', 'not found'),
                'description': table.get('description', 'not found'),
                'platforms': table.get('platforms', 'not found')
            }
            for table in SCHEMA
            if (platform is None or platform in table.get('platforms'))
                and not table.get('evented')
        ]
    }

@mcp.tool()
def get_table_schema(name: str) -> dict:
    """
    Retrieves the specific columns and types for a given table name.
    
    Instructions:
    * ALWAYS confirm the table `name` actually exists using `list_tables` before calling this tool.
    * ALWAYS use this tool to identify a table's columns before calling `run_query`.
    """
    try:
        data = next((table for table in SCHEMA if table.get('name') == name))
    except StopIteration:
        return {'error': 'Table does not exist.'}
    return {
        'examples': data.get('examples', []),
        'columns': [
            {
                'name': column.get('name', 'not found'),
                'description': column.get('description', 'not found'),
                'type': column.get('type', 'not found'),
                'required': column.get('required', 'not found'),
            }
            for column in data.get('columns', [])
        ]
    }

@mcp.tool()
async def query_tables_list(id: int) -> dict:
    """
    Runs a query to interrogate a host's exact supported tables list.
    This is a slow, targeted alternative to `list_tables`.
    
    Instructions:
    * ALWAYS prefer `list_tables` with the `platform` specifier when possible.
    * ONLY use this after queries using `list_tables` has resulted in unexpected behavior.
    * NEVER call this tool unless you have already made an equivalent call to `list_tables`.
    """
    try:
        data = await run_query_helper((
            'SELECT name FROM osquery_registry '
            'WHERE registry="table" AND active=true'
        ), id)
    except RuntimeError as e:
        return {'error': str(e)}
    return {
        'error': data.get('error', 'null'),
        'tables': [
            row['name']
            for row in data.get('rows', [])
            if 'name' in row
        ]
    }

@mcp.tool()
async def query_table_schema(table: str, id: int) -> dict:
    """
    Runs a query to interrogate a host's exact schema for a given table.
    This is a slow, targeted alternative to `get_table_schema`.

    Instructions:
    * ALWAYS prefer `get_table_schema` and `list_tables` when possible.
    * ONLY use this after queries using `get_table_schema` have failed.
    * NEVER call this tool unless you have already made an equivalent call to `get_table_schema`.
    """
    try:
        data = await run_query_helper((
            f'PRAGMA table_info("{table}")'
        ), id)
    except RuntimeError as e:
        return {'error': str(e)}
    return {
        'error': data.get('error', 'null'),
        'schema': data.get('rows', [])
    }

@mcp.tool()
async def query_build_platform(id: int) -> dict:
    """
    Runs a query to interrogate a host's exact osquery platform.
    The result is the appropriate `platform` for `list_tables`.
    This is a slower and costlier tool than `list_hosts`.

    Instructions:
    * ALWAYS prefer `list_hosts` over calling this tool.
    * NEVER call this tool unless you have already made a call to `list_hosts`.
    * ONLY use this tool when the platform cannot be inferred from a host's OS.
    """
    try:
        data = await run_query_helper((
            'SELECT build_platform FROM osquery_info'
        ), id)
    except RuntimeError as e:
        return {'error': str(e)}
    return {
        'error': data.get('error', 'null'),
        'platform': [
            row['build_platform']
            for row in data.get('rows', [])
            if 'build_platform' in row
        ]
    }

if __name__ == '__main__':
    if sys.argv[1] == 'stdio':
        mcp.run(transport='stdio')
    else:
        mcp.run(transport='http', host='0.0.0.0', port=8080)