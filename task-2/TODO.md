REQUIREMENTS
1️⃣ Reverse Proxy Layer
    - [x] NGINX container
    - [x] Hostda 8080 portundan açılmalıdır
    - [x] PHP requestləri application container-ə forward etməlidir
    - [x] Config external fayldan gəlməlidir (image içində olmamalıdır)
    - [x] Container database şəbəkəsinə çıxış edə bilməməlidir

2️⃣ Application Layer
    - [x] PHP-FPM container
    - [x] Source kod hostdan mount edilməlidir
    - [x] DB ilə əlaqə qurmalıdır
    - [x] Healthcheck olmalıdır
    - [x] Container crash edərsə restart olunmalıdır
    - [x] Root user ilə işləməməlidir

3️⃣ Database Layer
    - [x] MySQL 8 container
    - [x] Data persistent olmalıdır
    - [x] Root password plain text yazılmamalıdır
    - [x] Application user ayrıca yaradılmalıdır
    - [x] DB container internetə çıxışı olmamalıdır
    - [x] Healthcheck olmalıdır

Network Requirements
    - [x] Minimum 2 ayrı Docker network
    - [x] Frontend DB-yə birbaşa qoşula bilməməlidir
    - [x] Application həm DB, həm Front network-də olmalıdır

Security Requirements
    - [x] Secrets istifadə olunmalıdır

 Production Readiness
Aşağıdakılar əlavə olunmalıdır:
    - [x] Resource limits
    - [x] Proper restart policies
    - [x] Named volumes
    - [x] .env istifadəsi
    - [x] Logging stdout/stderr
