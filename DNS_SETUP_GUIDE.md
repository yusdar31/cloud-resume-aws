# Panduan Setup DNS untuk Domain andiyusdaralimran.my.id di Rumahweb

Panduan ini akan membantu Anda mengkonfigurasi DNS di Rumahweb untuk menghubungkan domain **andiyusdaralimran.my.id** dengan website Cloud Resume Challenge Anda di AWS CloudFront.

---

## 📋 Ringkasan Langkah-Langkah

1. Deploy infrastructure Terraform untuk membuat ACM certificate
2. Dapatkan DNS validation records dari Terraform output
3. Tambahkan CNAME records untuk validasi certificate di Rumahweb
4. Tunggu certificate tervalidasi (5-30 menit)
5. Tambahkan CNAME records untuk domain utama
6. Verifikasi website dapat diakses via custom domain

---

## 🚀 Langkah 1: Deploy Infrastructure

Jalankan Terraform untuk membuat ACM certificate:

```bash
cd "d:\Project AWS\cloud-resume-challange"
terraform init
terraform plan
terraform apply
```

Setelah selesai, Terraform akan menampilkan output termasuk `certificate_validation_records`.

---

## 🔐 Langkah 2: Dapatkan Certificate Validation Records

Jalankan command berikut untuk melihat DNS records yang perlu ditambahkan:

```bash
terraform output certificate_validation_records
```

Output akan terlihat seperti ini:

```
{
  "andiyusdaralimran.my.id" = {
    "name"  = "_abc123def456.andiyusdaralimran.my.id."
    "type"  = "CNAME"
    "value" = "_xyz789ghi012.acm-validations.aws."
  }
  "www.andiyusdaralimran.my.id" = {
    "name"  = "_def456ghi789.www.andiyusdaralimran.my.id."
    "type"  = "CNAME"
    "value" = "_jkl345mno678.acm-validations.aws."
  }
}
```

**PENTING:** Catat nilai `name` dan `value` untuk kedua domain.

---

## 🌐 Langkah 3: Tambahkan Validation Records di Rumahweb

### A. Login ke Panel Rumahweb

1. Buka https://clientzone.rumahweb.com/
2. Login dengan akun Anda
3. Pilih menu **Domain** → **My Domains**
4. Klik domain **andiyusdaralimran.my.id**
5. Pilih tab **DNS Management** atau **Manage DNS**

### B. Tambahkan CNAME Records untuk Validasi

Untuk **setiap** validation record yang Anda dapatkan dari Terraform output:

1. Klik tombol **Add Record** atau **Add New Record**
2. Pilih **Type**: `CNAME`
3. **Name/Host**: 
   - Ambil dari output `name`, tapi **HAPUS** nama domain di belakangnya
   - Contoh: jika `name` = `_abc123def456.andiyusdaralimran.my.id.`
   - Maka isi dengan: `_abc123def456`
4. **Value/Points To**: 
   - Copy **PERSIS** dari output `value`
   - Contoh: `_xyz789ghi012.acm-validations.aws.`
5. **TTL**: Biarkan default atau set `3600`
6. Klik **Save** atau **Add Record**

**Ulangi** untuk validation record kedua (www subdomain).

> [!TIP]
> Beberapa DNS panel Rumahweb otomatis menambahkan domain di belakang, jadi Anda hanya perlu isi bagian `_abc123def456` saja tanpa `.andiyusdaralimran.my.id.`

---

## ⏳ Langkah 4: Tunggu Certificate Validation

Setelah menambahkan CNAME records:

1. Tunggu **5-30 menit** untuk DNS propagation
2. AWS akan otomatis memvalidasi certificate
3. Cek status certificate di AWS Console atau jalankan:

```bash
aws acm list-certificates --region us-east-1
```

Atau cek via Terraform:

```bash
terraform refresh
terraform output
```

Certificate sudah tervalidasi jika statusnya **ISSUED**.

---

## 🎯 Langkah 5: Tambahkan DNS Records untuk Domain Utama

Setelah certificate tervalidasi, dapatkan CloudFront domain name:

```bash
terraform output cloudfront_domain_name
```

Output contoh: `d1234abcd5678.cloudfront.net`

### Tambahkan Records di Rumahweb:

#### Record 1: Root Domain (andiyusdaralimran.my.id)

**PENTING:** Untuk root domain, Rumahweb mungkin **tidak support CNAME**. Gunakan salah satu opsi berikut:

**Opsi A: Jika Rumahweb Support CNAME Flattening/ALIAS**
- **Type**: `CNAME` atau `ALIAS`
- **Name**: `@` atau kosongkan
- **Value**: `d1234abcd5678.cloudfront.net` (dari Terraform output)
- **TTL**: `3600`

**Opsi B: Jika Rumahweb TIDAK Support CNAME untuk Root Domain**
- Gunakan **A Record** dengan IP CloudFront (tidak recommended, karena IP bisa berubah)
- Atau gunakan **URL Redirect** dari `andiyusdaralimran.my.id` ke `www.andiyusdaralimran.my.id`

#### Record 2: WWW Subdomain

- **Type**: `CNAME`
- **Name**: `www`
- **Value**: `d1234abcd5678.cloudfront.net`
- **TTL**: `3600`

> [!WARNING]
> **Root Domain Limitation**
> Domain .my.id di Rumahweb mungkin tidak support CNAME untuk root domain. Jika demikian, gunakan URL redirect atau hubungi support Rumahweb untuk opsi ALIAS/CNAME Flattening.

---

## ✅ Langkah 6: Verifikasi Website

Setelah menambahkan DNS records, tunggu **5-15 menit** untuk DNS propagation, lalu test:

```bash
# Test DNS resolution
nslookup andiyusdaralimran.my.id
nslookup www.andiyusdaralimran.my.id

# Test HTTPS access
curl -I https://andiyusdaralimran.my.id
curl -I https://www.andiyusdaralimran.my.id
```

Atau buka di browser:
- https://andiyusdaralimran.my.id
- https://www.andiyusdaralimran.my.id

Keduanya harus menampilkan website Anda dengan **SSL/HTTPS** yang valid (gembok hijau).

---

## 🔧 Troubleshooting

### Certificate Tidak Tervalidasi Setelah 30 Menit

1. Cek apakah CNAME records sudah benar di DNS Rumahweb
2. Pastikan tidak ada typo di `name` dan `value`
3. Cek DNS propagation: https://dnschecker.org/
4. Hapus dan tambahkan ulang CNAME records jika perlu

### Website Tidak Bisa Diakses

1. Pastikan certificate sudah status **ISSUED**
2. Cek DNS records sudah benar pointing ke CloudFront
3. Tunggu DNS propagation (bisa sampai 24 jam, tapi biasanya 5-15 menit)
4. Clear browser cache atau test di incognito mode
5. Test dengan `dig` atau `nslookup`:
   ```bash
   dig andiyusdaralimran.my.id
   ```

### SSL Certificate Error di Browser

1. Pastikan menggunakan **HTTPS** bukan HTTP
2. Certificate mungkin belum tervalidasi, cek status di AWS Console
3. Clear browser SSL cache
4. Test di browser lain atau incognito mode

### Root Domain Tidak Bisa Pakai CNAME

Ini limitasi DNS standar. Solusi:
1. Hubungi support Rumahweb untuk opsi ALIAS atau CNAME Flattening
2. Gunakan URL redirect dari root ke www subdomain
3. Atau gunakan A record (tidak recommended)

---

## 📞 Support

Jika mengalami kesulitan:
- **Rumahweb Support**: https://www.rumahweb.com/support
- **AWS Support**: https://console.aws.amazon.com/support/

---

## 🎉 Selesai!

Setelah semua langkah selesai, website Cloud Resume Challenge Anda akan dapat diakses via:
- **https://andiyusdaralimran.my.id** ✅
- **https://www.andiyusdaralimran.my.id** ✅

Dengan SSL certificate yang valid dan otomatis renew selamanya! 🚀
