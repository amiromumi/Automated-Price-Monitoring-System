# سیستم خودکار مانیتورینگ قیمت‌ها

یک پروژه سبک، ماژولار و قابل توسعه برای مانیتورینگ قیمت بازار و ارسال هشدار از طریق تلگرام و اعلان محلی دسکتاپ لینوکس. پیاده‌سازی فعلی قیمت USDT/IRR را از API عمومی رمزینکس دریافت می‌کند و ساختار پروژه برای افزودن دارایی‌ها و سیستم‌عامل‌های دیگر آماده است.

[English documentation](README.md)

## ویژگی‌ها

- دریافت قیمت خرید و فروش تتر و درصد تغییرات ۲۴ ساعت
- گزارش زمان‌بندی‌شده قیمت
- مانیتور محدوده خرید قابل تنظیم
- ارسال پیام از طریق Telegram Bot API
- اعلان دسکتاپ لینوکس با `notify-send`
- جلوگیری از ارسال مکرر هشدار محدوده خرید با فایل وضعیت
- پیاده‌سازی سبک با Bash و Python و بدون وابستگی به LLM
- ساختار ماژولار بر اساس `سیستم‌عامل/دارایی`

## معماری

```text
Ramzinex REST API
        |
        v
اسکریپت Bash + پردازش JSON با Python
        |
        +--> Telegram Bot API (هشدار راه دور)
        |
        +--> notify-send (اعلان محلی)
        |
        +--> فایل وضعیت محلی (جلوگیری از هشدار تکراری)
```

## ساختار مخزن

```text
.
├── docs/
│   ├── telegram-bot-setup.md
│   └── telegram-bot-setup-fa.md
├── Linux/
│   ├── README.md
│   ├── README-fa.md
│   └── usdt/
│       ├── tether_price.sh   # گزارش دوره‌ای قیمت
│       ├── tether_alert.sh   # مانیتور ورود و خروج از محدوده خرید
│       ├── README.md
│       └── README-fa.md
├── Windows/
│   └── usdt/
│       ├── tether_price.ps1
│       ├── tether_alert.ps1
│       ├── README.md
│       └── README-fa.md
├── README.md
└── README-fa.md
```

## فناوری‌های استفاده‌شده

- Bash / Shell scripting
- Python 3 برای پردازش JSON
- `curl` برای درخواست‌های HTTP
- زمان‌بندی سازگار با Cron
- Telegram Bot API
- `libnotify` / `notify-send`

## شروع سریع

### ۱. کلون کردن مخزن

```bash
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System
```

### ۲. راه‌اندازی بات تلگرام

پیش از استفاده از هر اسکریپتی، به توکن بات تلگرام و Chat ID نیاز دارید. [راهنمای راه‌اندازی بات تلگرام](docs/telegram-bot-setup-fa.md) را دنبال کنید (۵ دقیقه).

### ۳. نصب و تنظیم

```bash
cd Linux/usdt
mkdir -p "$HOME/scripts"
cp tether_price.sh tether_alert.sh "$HOME/scripts/"
chmod +x "$HOME/scripts/tether_price.sh" "$HOME/scripts/tether_alert.sh"
```

در هر دو فایل کپی‌شده، مقادیر `YOUR_BOT_TOKEN` و `YOUR_CHAT_ID` را جایگزین کنید.

### ۴. تست

```bash
bash "$HOME/scripts/tether_price.sh"
bash "$HOME/scripts/tether_alert.sh"
```

### ۵. زمان‌بندی

```bash
crontab -e
```

```cron
0 * * * * /home/yourusername/scripts/tether_price.sh
*/2 * * * * /home/yourusername/scripts/tether_alert.sh
```

برای جزئیات بیشتر، [راهنمای لینوکس](Linux/README-fa.md) و [راهنمای کامل USDT](Linux/usdt/README-fa.md) را ببینید.

## رفتار اعلان‌ها

- اسکریپت `tether_price.sh` در هر بار اجرا یک گزارش ارسال می‌کند.
- اسکریپت `tether_alert.sh` در هر اجرای زمان‌بندی‌شده قیمت را بررسی می‌کند، اما فقط هنگام تغییر وضعیت از خارج محدوده به داخل محدوده خرید هشدار می‌دهد. هنگام خروج بعدی قیمت نیز پیام خروج ارسال می‌شود.
- تلگرام فقط زمانی هنگام خاموش بودن نمایشگر یا قفل بودن سیستم پیام می‌گیرد که خود کامپیوتر، زمان‌بند و شبکه همچنان فعال باشند.
- اعلان دسکتاپ به نشست گرافیکی فعال نیاز دارد. هنگام Suspend بودن سیستم، در دسترس نبودن نشست گرافیکی یا نداشتن دسترسی زمان‌بند به D-Bus ممکن است نمایش داده نشود.

## امنیت

- توکن واقعی بات، Chat ID، کلید API یا اطلاعات خصوصی پراکسی را هرگز در Git کامیت نکنید.
- نسخه مخزن باید همیشه مقادیر نمونه و Placeholder داشته باشد.
- اگر توکن تلگرام عمومی شد، فوراً آن را با BotFather باطل و دوباره ایجاد کنید.
- فایل محلی حاوی اطلاعات حساس را با `chmod 600` محدود کنید.

## عیب‌یابی

۱. اسکریپت را دستی اجرا و کد خروج آن را بررسی کنید.
۲. دسترسی به API و پراکسی را آزمایش کنید.
۳. توکن بات و Chat ID را تأیید کنید.
۴. فعال بودن سرویس زمان‌بند را بررسی کنید.
۵. در زمان‌بندی از مسیرهای مطلق استفاده کنید.
۶. مطمئن شوید `curl`، `python3` و `notify-send` در محیط زمان‌بند در دسترس‌اند.
۷. ارسال تلگرام و اعلان دسکتاپ دو کانال مستقل هستند؛ ممکن است یکی کار کند و دیگری نه.

این مخزن عمداً فاقد بخش لایسنس و اطلاعات ورود واقعی است.
