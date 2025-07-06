window.addEventListener('message', function(event) {
    const item = event.data;
    
    if (item.type === "showKTP") {
        const ktpData = item.data;
        document.getElementById('nik-value').innerText = ktpData.nik || 'N/A';
        document.getElementById('nama-value').innerText = ktpData.nama || 'N/A';
        document.getElementById('ttl-value').innerText = ktpData.ttl || 'N/A';
        document.getElementById('gender-value').innerText = ktpData.gender || 'N/A';
        document.getElementById('pekerjaan-value').innerText = ktpData.pekerjaan || 'TIDAK BEKERJA';
        document.getElementById('telepon-value').innerText = ktpData.telepon || 'TIDAK TERDAFTAR';
        document.getElementById('kewarganegaraan-value').innerText = ktpData.nationality || 'INDONESIA';
        document.getElementById('foto-value').src = ktpData.fotourl || '';
        const berlakuEl = document.getElementById('berlaku-value');
        if (ktpData.expires) {
            const today = new Date();
            const expiryDate = new Date(ktpData.expires);
            today.setHours(0, 0, 0, 0);
            if (expiryDate < today) {
                berlakuEl.innerText = 'KADALUARSA';
                berlakuEl.classList.add('expired');
            } else {
                const day = String(expiryDate.getDate()).padStart(2, '0');
                const month = String(expiryDate.getMonth() + 1).padStart(2, '0');
                const year = expiryDate.getFullYear();
                berlakuEl.innerText = `${day}-${month}-${year}`;
                berlakuEl.classList.remove('expired');
            }
        } else {
            berlakuEl.innerText = 'SEUMUR HIDUP';
            berlakuEl.classList.remove('expired');
        }
        document.getElementById('ktp-container').style.display = 'block';
    }

    if (item.type === "hideKTP") {
        document.getElementById('ktp-container').style.display = 'none';
    }
});