async function deploy() {
    const sql = document.getElementById('sql').value;
    document.getElementById('status').innerText = "Deploying...";
    document.getElementById('table-container').innerHTML = "<em>Waiting for agents...</em>";
    
    await fetch('/api/deploy', {
        method: 'POST',
        headers: {'Content-Type': 'application/json'},
        body: JSON.stringify({query: sql})
    });
}

async function poll() {
    const res = await fetch('/api/results');
    const data = await res.json(); 
    
    let flatRows = [];
    let columns = new Set();
    
    for (const [hostname, rows] of Object.entries(data)) {
        if (rows.length === 0) continue;
        Object.keys(rows[0]).forEach(k => columns.add(k));
        rows.forEach(row => {
            flatRows.push({ _hostname: hostname, ...row });
        });
    }

    if (flatRows.length === 0) return;

    document.getElementById('status').innerText = `Received ${flatRows.length} rows.`;
    flatRows.sort((a, b) => a._hostname.localeCompare(b._hostname));

    let html = "<table><thead><tr><th>Hostname</th>";
    const colArray = Array.from(columns).sort();
    
    colArray.forEach(col => { html += `<th>${col}</th>`; });
    html += "</tr></thead><tbody>";

    flatRows.forEach(row => {
        html += "<tr>";
        html += `<td class="hostname-col">${row._hostname}</td>`;
        colArray.forEach(col => {
            html += `<td>${row[col] !== undefined ? row[col] : ''}</td>`;
        });
        html += "</tr>";
    });
    html += "</tbody></table>";

    document.getElementById('table-container').innerHTML = html;
}

// Start polling
setInterval(poll, 2000);