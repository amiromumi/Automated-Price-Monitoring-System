# مانیتورینگ تتر در لینوکس

دو اسکریپت سبک، قیمت USDT/IRR را با API عمومی رمزینکس مانیتور می‌کنند.

[English documentation](README.md)

## اسکریپت‌ها

| اسکریپت | کاربرد | زمان‌بندی پیشنهادی |
|---|---|---|
| `tether_price.sh` | در هر اجرا قیمت خرید، فروش و تغییر ۲۴ ساعت را ارسال می‌کند | هر ساعت |
| `tether_alert.sh` | محدوده خرید را بررسی می‌کند و فقط هنگام تغییر وضعیت پیام می‌دهد | هر ۲ تا ۵ دقیقه |

## پیش‌نیازها

- لینوکس
- Bash
- `curl`
- Python 3
- `notify-send` از بسته `libnotify` برای اعلان دسکتاپ
- توکن بات تلگرام و Chat ID مقصد
- پراکسی SOCKS5 به‌صورت اختیاری

Debian/Ubuntu:

```bash
sudo apt update
sudo apt install -y curl python3 libnotify-bin cron
```

## راه‌اندازی بات تلگرام (یک‌بار، قبل از هر کاری)

اسکریپت‌ها به یک بات تلگرام و Chat ID شخصی شما نیاز دارند. این‌ها را یک‌بار بسازید:

### ۱. ساخت بات

۱. تلگرام را باز کنید و **@BotFather** را جستجو کنید (تیک آبی تأیید داشته باشد).
۲. دستور `/newbot` را بفرستید.
۳. یک نام نمایشی انتخاب کنید (هر چیزی، مثلاً `مانیتور قیمت من`).
۴. یک نام کاربری که به `bot` ختم شود انتخاب کنید (مثلاً `my_price_monitor_bot`).
۵. BotFather یک **توکن** مانند `1234567890:AAxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx` می‌فرستد. آن را کپی و نگه دارید — این همان `BOT_TOKEN` شماست.

### ۲. گرفتن Chat ID

۱. در تلگرام، **@userinfobot** را جستجو کنید و هر پیامی (مثلاً `hi`) بفرستید.
۲. این بات اطلاعات حساب شما را می‌فرستد. عدد کنار **Id** همان `CHAT_ID` شماست.
۳. نکته مهم: با بات جدید خودتان یک گفت‌وگو باز کرده و دکمه **Start** را بزنید (یا `/start` بفرستید). بات تا زمانی که شما یک‌بار او را استارت نکرده باشید نمی‌تواند برایتان پیام بفرستد.

### ۳. تست بات (اختیاری اما توصیه‌شده)

```bash
curl -s "https://api.telegram.org/botYOUR_BOT_TOKEN/sendMessage" \
  -d "chat_id=YOUR_CHAT_ID" \
  --data-urlencode "text=Test"
```

اگر پاسخ شامل `"ok":true` بود و پیام تست در تلگرام رسید، اطلاعات شما درست است. اگر تلگرام روی شبکه شما فیلتر است، گزینه `--proxy socks5h://127.0.0.1:10808` را با آدرس و پورت پراکسی خودتان اضافه کنید.

## نصب

ابتدا ابزارهای لازم را نصب کنید، مخزن را Clone کرده و اسکریپت‌ها را کپی کنید:

```bash
# ۱. نصب پیش‌نیازها (Debian/Ubuntu؛ در توزیع‌های دیگر از Package Manager خود استفاده کنید)
sudo apt update
sudo apt install -y curl python3 libnotify-bin cron git

# ۲. کلون کردن مخزن
git clone https://github.com/amiromumi/Automated-Price-Monitoring-System.git
cd Automated-Price-Monitoring-System/Linux/usdt

# ۳. کپی اسکریپت‌ها به یک مسیر پایدار
mkdir -p "$HOME/scripts"
cp tether_price.sh tether_alert.sh "$HOME/scripts/"

# ۴. اجرایی کردن اسکریپت‌ها
chmod +x "$HOME/scripts/tether_price.sh" "$HOME/scripts/tether_alert.sh"
```

اگر ممکن است پوشه Clone جابه‌جا یا حذف شود، فایل‌ها را مستقیماً از داخل آن زمان‌بندی نکنید. از مسیر پایداری مانند `$HOME/scripts` استفاده کنید.


## تنظیمات

هر دو نسخه محلی را ویرایش کنید:

```bash
nano "$HOME/scripts/tether_price.sh"
nano "$HOME/scripts/tether_alert.sh"
```

مقادیر زیر را جایگزین کنید:

```bash
BOT_TOKEN="YOUR_BOT_TOKEN"
CHAT_ID="YOUR_CHAT_ID"
```

پراکسی پیش‌فرض:

```bash
PROXY="socks5h://127.0.0.1:10808"
```

اگر به پراکسی نیاز ندارید، گزینه `--proxy "$PROXY"` را از فراخوانی‌های Telegram حذف کنید یا اسکریپت را برای پراکسی خالی تغییر دهید. اطلاعات واقعی را هرگز کامیت نکنید.

### واحد محدوده خرید

در `tether_alert.sh` حدها برحسب ریال ذخیره می‌شوند:

```bash
LOWER_BOUND=1800000
UPPER_BOUND=2000000
```

چون هر تومان برابر ۱۰ ریال است، این مقادیر نمونه محدوده ۱۸۰٬۰۰۰ تا ۲۰۰٬۰۰۰ تومان را نشان می‌دهند.

## تست دستی

```bash
bash "$HOME/scripts/tether_price.sh"
printf 'price exit code: %s\n' "$?"

bash "$HOME/scripts/tether_alert.sh"
printf 'alert exit code: %s\n' "$?"
```

ممکن است `tether_alert.sh` با وجود اجرای موفق هیچ پیامی ندهد. وقتی وضعیت قیمت تغییر نکرده باشد، این رفتار طبیعی است. فایل `/tmp/.tether_alert_state` از پیام‌های تکراری جلوگیری می‌کند:

- `OUT -> IN_ZONE`: ارسال هشدار خرید
- `IN_ZONE -> IN_ZONE`: بدون پیام
- `IN_ZONE -> OUT`: ارسال پیام خروج
- `OUT -> OUT`: بدون پیام

فقط اگر عمداً می‌خواهید سابقه وضعیت پاک شود، فایل را حذف کنید:

```bash
rm -f /tmp/.tether_alert_state
```

## زمان‌بندی با Cron استاندارد

Crontab کاربر فعلی را باز کنید:

```bash
crontab -e
```

خطوط زیر را اضافه و `yourusername` را جایگزین کنید:

```cron
0 * * * * /home/yourusername/scripts/tether_price.sh >> /home/yourusername/tether_price.log 2>&1
*/2 * * * * /home/yourusername/scripts/tether_alert.sh >> /home/yourusername/tether_alert.log 2>&1
```

تنظیمات و سرویس را بررسی کنید:

```bash
crontab -l
systemctl status cron
```

نمونه زمان‌بندی‌ها:

- `0 * * * *`: هر ساعت در دقیقه صفر
- `*/30 * * * *`: هر ۳۰ دقیقه
- `*/2 * * * *`: هر ۲ دقیقه
- `*/5 * * * *`: هر ۵ دقیقه

## زمان‌بندی اختیاری با Hermes

این مخزن برای اجرا به Hermes Agent نیاز ندارد. اگر Hermes cron را انتخاب می‌کنید، اسکریپت‌ها را در پوشه اسکریپت Hermes کپی کرده و Gateway را فعال نگه دارید:

```bash
cp "$HOME/scripts/tether_price.sh" "$HOME/.hermes/scripts/"
cp "$HOME/scripts/tether_alert.sh" "$HOME/.hermes/scripts/"
hermes gateway install --start-now --start-on-login
hermes gateway status
hermes cron status
```

از جاب‌های اسکریپتی `no_agent` استفاده کنید. خود اسکریپت‌ها تلگرام و اعلان دسکتاپ را ارسال می‌کنند؛ بنابراین تحویل زمان‌بند باید محلی باشد تا ارسال تکراری یا خطای مقصد Gateway ایجاد نشود.

## Sleep، قفل صفحه و اعلان دسکتاپ

- صفحه قفل و سیستم بیدار: جاب‌ها معمولاً ادامه پیدا می‌کنند.
- سیستم Suspend/Sleep: اسکریپت‌ها تا زمان بیدار شدن اجرا نمی‌شوند و اجرای ازدست‌رفته ممکن است حذف یا با تأخیر اجرا شود.
- تلگرام: اگر کامپیوتر، زمان‌بند، پراکسی و شبکه فعال باشند، به نشست گرافیکی وابسته نیست.
- اعلان دسکتاپ: به نشست گرافیکی و D-Bus نیاز دارد و ممکن است در Suspend یا در محیط زمان‌بند بدون متغیرهای نشست نمایش داده نشود.

## عیب‌یابی

### پیام تلگرام نمی‌رسد

۱. همان اسکریپت را دستی اجرا کنید.
۲. توکن بات و Chat ID را بررسی کنید.
۳. پراکسی تنظیم‌شده را آزمایش کنید.
۴. برای عیب‌یابی، موقتاً پاسخ Telegram API را به `/dev/null` نفرستید.
۵. مطمئن شوید بات مسدود نیست و گفت‌وگوی مقصد وجود دارد.

### اعلان دسکتاپ نمی‌رسد

```bash
notify-send "USDT monitor test" "Desktop notifications are available"
```

اگر اجرای دستی کار می‌کند اما اجرای زمان‌بندی‌شده نه، نشست گرافیکی، `DISPLAY` و `DBUS_SESSION_BUS_ADDRESS` را بررسی یا از systemd timer سطح کاربر استفاده کنید.

### جاب زمان‌بندی‌شده اجرا نمی‌شود

- فعال بودن سرویس زمان‌بند را بررسی کنید.
- از مسیر مطلق استفاده کنید.
- با `ls -l "$HOME/scripts"` دسترسی اجرا را بررسی کنید.
- فایل‌های لاگ نمونه Cron را بخوانید.
- مطمئن شوید سیستم در زمان مقرر بیدار بوده است.
- برای Hermes cron، دستورهای `hermes gateway status` و `hermes cron status` را اجرا کنید.

## امنیت

- اسکریپت‌های مخزن عمداً از Placeholder استفاده می‌کنند.
- توکن تلگرام، Chat ID، اطلاعات خصوصی پراکسی یا مسیرهای حاوی راز را کامیت نکنید.
- اگر توکن افشا شد، آن را با BotFather باطل و توکن تازه تولید کنید.
- برای محیط عملیاتی، اطلاعات حساس را در فایل جداگانه با دسترسی `600` نگهداری کنید.

این پروژه عمداً بخش لایسنس ندارد.
