# Aaj Kya Banau

Flutter kitchen companion with four screens:

1. **Pantry (Home)** — pantry list, manual add, camera-scan simulation  
2. **Recipes** — dishes ranked by what you have; missing ingredients in red  
3. **Planner** — Monday–Sunday dinners plus a 7:00 PM reminder toggle  
4. **Cart** — missing groceries with a Blinkit Delivery checkout  

## Run

Flutter SDK is required (`flutter` on your PATH).

```bash
cd aaj_kya_banau
flutter create . --project-name aaj_kya_banau --org com.aajkyabanau
flutter pub get
flutter run
```

`flutter create .` generates Android, iOS, and other platform folders without overwriting `lib/`.

## Try it

- Tap **Camera scan** — wait for detection, then add Paneer, Capsicum, Curd, and Coriander.  
- Open **Recipes** — match % updates; missing items stay red.  
- **Add missing to cart** or **Plan** a dish onto a weekday.  
- Toggle **Evening reminder** on the planner.  
- Open **Cart** and tap **Blinkit Delivery**.
