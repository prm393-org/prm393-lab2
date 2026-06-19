# Journal Trend Analyzer — PRM393 Lab2

Ứng dụng Flutter phân tích xu hướng nghiên cứu học thuật, dữ liệu lấy động từ [OpenAlex API](https://docs.openalex.org/). Không backend riêng, không hard-code dữ liệu.

## Bắt đầu

```bash
flutter pub get
cp .env.example .env   # rồi điền OPENALEX_API_KEY (tùy chọn) + OPENALEX_MAILTO
flutter run            # Android / iOS
```

> Lấy API key miễn phí: https://openalex.org/settings/api — hoặc nhập trực tiếp trong tab Profile.

## Kiến trúc

Clean Architecture, tổ chức theo **feature-first**. Mỗi feature có 3 tầng `data` / `domain` / `presentation`.

```
lib/
├── main.dart                  # Entry: load .env, DI, runApp
├── app.dart                   # Root MaterialApp.router
├── core/                      # Hạ tầng dùng chung
│   ├── config/                # AppConfig (đọc .env)
│   ├── constants/             # AppConstants (endpoint, key prefs...)
│   ├── di/                    # injection.dart (get_it)
│   ├── error/                 # exceptions + failures
│   ├── network/               # ApiClient (Dio) + NetworkInfo
│   ├── router/                # app_router.dart (go_router)
│   ├── theme/                 # colors / typography / theme
│   ├── usecase/               # base UseCase<T, Params>
│   ├── utils/                 # AbstractDecoder, NumberFormatter
│   └── widgets/               # Loading / Error / Empty states
└── features/
    ├── home/                  # Tab Home  — khám phá & chọn topic   (Task 1)
    ├── journal/               # Tab Journal — publications + detail  (Task 1)
    ├── keywords/              # Tab Keywords — trends & analytics    (Task 2/3)
    ├── profile/               # Tab Profile — settings & about       (Task 4)
    └── shared/                # SelectedTopicCubit + MainScaffold
```

Mỗi feature:

```
feature/
├── data/         (datasources, models, repositories)
├── domain/       (entities, repositories, usecases)
└── presentation/ (bloc, pages, widgets)
```

## Stack

| Mục | Package |
|-----|---------|
| State management | `flutter_bloc`, `equatable` |
| DI | `get_it` |
| Network | `dio`, `connectivity_plus` |
| Functional error | `dartz` (`Either<Failure, T>`) |
| Navigation | `go_router` |
| Charts | `fl_chart` |
| Local storage | `shared_preferences` |
| Env / secret | `flutter_dotenv` |
| Khác | `url_launcher`, `intl` |

## Phân chia công việc

Xem `PHAN_CHIA_4_TASK.md`. Đề bài chi tiết: `LAB2_PHAN_TICH_DE_BAI.md`. Hướng dẫn API: `OPENALEX_API_HUONG_DAN.md`.
