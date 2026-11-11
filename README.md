# Pasargad WireGuard VPN (Android APK via GitHub Actions)

این مخزن شامل سورس کامل پروژه فلاتر **Pasargad VPN** به همراه فایل اتوماسیون **GitHub Actions** (`.github/workflows/build-apk.yml`) برای ساخت خودکار فایل نصبی اندروید (`app-release.apk`) است.

## نحوه تبدیل به APK در گیت‌هاب (GitHub Actions)

1. محتویات این فایل فشرده (`pasargad_vpn_github_project.zip`) را از حالت فشرده خارج کنید.
2. قبل از آپلود، در فایل `lib/core/constants/app_constants.dart` آدرس پنل خود (`baseUrl`) و کلید API ادمین (`panelAdminApiKey`) را جایگزین کنید.
3. یک مخزن (Repository) جدید در گیت‌هاب بسازید و تمام فایل‌ها و پوشه‌ها (از جمله پوشه مخفی `.github`) را در شاخه `main` آپلود یا Push کنید.
4. وارد تب **Actions** در مخزن گیت‌هاب خود شوید؛ ورک‌فلوی **Build Pasargad VPN APK** به صورت خودکار اجرا شده و پس از حدود ۳ تا ۵ دقیقه، فایل نهایی در بخش **Artifacts** با نام `Pasargad-VPN-Release-APK` آماده دانلود خواهد بود.

## ورود به پنل مخفی ادمین داخل اپلیکیشن
- در صفحه ورود کاربر، **۵ بار پشت سر هم** روی آیکون سپر (Shield) در بالای صفحه ضربه بزنید تا صفحه ورود ادمین باز شود.
- رمز عبور پیش‌فرض ادمین: `P@s$w0rd_Admin_Pasargad!2026#X`
