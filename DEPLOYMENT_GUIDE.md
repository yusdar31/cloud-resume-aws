# 🚀 Deployment Guide - Custom Domain Integration

Ada **2 cara** untuk deploy custom domain ke project ini. Pilih salah satu sesuai preferensi Anda.

---

## ⚡ Opsi 1: Deploy Bertahap (RECOMMENDED untuk Pemula)

Deploy dalam 2 tahap - buat certificate dulu, validasi manual, baru deploy CloudFront.

### Langkah 1: Comment Out Certificate Validation

Edit file `acm.tf`, comment out bagian validation:

```hcl
# Certificate Validation - menunggu sampai certificate tervalidasi
# CATATAN: Ini akan HANG sampai Anda menambahkan DNS records ke Rumahweb!
# Jika Anda belum siap validasi, comment out resource ini dulu
# resource "aws_acm_certificate_validation" "ssl_validation" {
#   provider        = aws.us_east_1
#   certificate_arn = aws_acm_certificate.ssl_certificate.arn
#
#   timeouts {
#     create = "45m"
#   }
# }
```

### Langkah 2: Comment Out CloudFront depends_on

Edit file `main.tf`, comment out `depends_on`:

```hcl
resource "aws_cloudfront_distribution" "s3_distribution" {
  # Tunggu sampai certificate tervalidasi sebelum membuat CloudFront
  # depends_on = [aws_acm_certificate_validation.ssl_validation]
```

### Langkah 3: Deploy Certificate Saja

```bash
terraform apply -target=aws_acm_certificate.ssl_certificate
```

### Langkah 4: Dapatkan Validation Records

```bash
terraform output certificate_validation_records
```

### Langkah 5: Tambahkan DNS Records ke Rumahweb

Ikuti panduan di [DNS_SETUP_GUIDE.md](file:///d:/Project%20AWS/cloud-resume-challange/DNS_SETUP_GUIDE.md) bagian "Langkah 3".

### Langkah 6: Tunggu Certificate Tervalidasi

Cek status di AWS Console atau:

```bash
aws acm describe-certificate --certificate-arn $(terraform output -raw certificate_arn) --region us-east-1
```

Tunggu sampai status = `ISSUED` (5-30 menit).

### Langkah 7: Uncomment Validation & Deploy Full

Setelah certificate `ISSUED`, uncomment kembali code yang di-comment di Langkah 1 & 2, lalu:

```bash
terraform apply
```

---

## 🔥 Opsi 2: Deploy Otomatis (RECOMMENDED untuk Advanced User)

Terraform akan otomatis menunggu certificate validation. Anda harus **siap** menambahkan DNS records ke Rumahweb dalam 45 menit.

### Langkah 1: Deploy Semuanya

```bash
terraform apply
```

Terraform akan membuat certificate dan **HANG** menunggu validasi.

### Langkah 2: Dapatkan Validation Records (Terminal Baru)

Buka terminal baru (jangan close yang sedang `terraform apply`), lalu:

```bash
cd "d:\Project AWS\cloud-resume-challange"
terraform output certificate_validation_records
```

### Langkah 3: Tambahkan DNS Records ke Rumahweb

Ikuti panduan di [DNS_SETUP_GUIDE.md](file:///d:/Project%20AWS/cloud-resume-challange/DNS_SETUP_GUIDE.md) bagian "Langkah 3".

### Langkah 4: Tunggu Terraform Selesai

Setelah DNS records ditambahkan, Terraform akan otomatis detect validasi dan melanjutkan deployment CloudFront (5-30 menit).

Jika timeout (45 menit), jalankan ulang:

```bash
terraform apply
```

---

## 🎯 Langkah Setelah Deployment Selesai

### 1. Dapatkan CloudFront Domain

```bash
terraform output cloudfront_domain_name
```

Output contoh: `d1234abcd5678.cloudfront.net`

### 2. Tambahkan DNS Records untuk Domain

Di Rumahweb DNS panel, tambahkan:

**Root Domain:**
- Type: `CNAME` atau `ALIAS`
- Name: `@` atau kosongkan
- Value: `d1234abcd5678.cloudfront.net`

**WWW Subdomain:**
- Type: `CNAME`
- Name: `www`
- Value: `d1234abcd5678.cloudfront.net`

### 3. Verifikasi

Tunggu 5-15 menit, lalu test:

```bash
curl -I https://andiyusdaralimran.my.id
```

Atau buka di browser: **https://andiyusdaralimran.my.id**

---

## 🆘 Troubleshooting

### Error: "Error creating CloudFront Distribution: InvalidViewerCertificate"

**Penyebab:** Certificate belum tervalidasi.

**Solusi:** Gunakan Opsi 1 (Deploy Bertahap) atau pastikan DNS validation records sudah ditambahkan ke Rumahweb.

### Terraform Hang Lebih dari 45 Menit

**Penyebab:** DNS validation records belum ditambahkan atau salah.

**Solusi:**
1. Ctrl+C untuk cancel
2. Cek DNS records di Rumahweb
3. Perbaiki jika ada typo
4. Jalankan ulang `terraform apply`

### Certificate Status Masih "Pending Validation"

**Penyebab:** DNS belum propagate atau CNAME records salah.

**Solusi:**
1. Cek DNS propagation: https://dnschecker.org/
2. Verifikasi CNAME records di Rumahweb panel
3. Tunggu 5-30 menit untuk DNS propagation

---

## 📚 Referensi

- [DNS_SETUP_GUIDE.md](file:///d:/Project%20AWS/cloud-resume-challange/DNS_SETUP_GUIDE.md) - Panduan lengkap DNS configuration
- [implementation_plan.md](file:///C:/Users/andi.yusdar/.gemini/antigravity/brain/da55185e-6894-4969-81d6-ab024bc9cdab/implementation_plan.md) - Technical implementation details
- [walkthrough.md](file:///C:/Users/andi.yusdar/.gemini/antigravity/brain/da55185e-6894-4969-81d6-ab024bc9cdab/walkthrough.md) - What was changed

---

## ✅ Pilihan Saya

**Untuk Anda, saya rekomendasikan Opsi 1 (Deploy Bertahap)** karena:
- Lebih mudah untuk pemula
- Tidak perlu worry tentang timeout
- Bisa validasi certificate dengan tenang
- Lebih jelas step-by-step

Silakan pilih opsi yang sesuai dengan preferensi Anda! 🚀
