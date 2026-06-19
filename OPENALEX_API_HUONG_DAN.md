# Hướng dẫn gọi OpenAlex API cho Lab2 – Journal Trend Analyzer

> Tài liệu tham chiếu đầy đủ: lần sau đọc file này là có thể gọi API, lấy đủ data cho toàn bộ đề bài PRM393 Lab2.  
> Docs chính thức: [OpenAlex API Overview](https://developers.openalex.org/api-reference/introduction)

---

## Mục lục

1. [Thông tin cơ bản](#1-thông-tin-cơ-bản)
2. [Cấu trúc response](#2-cấu-trúc-response)
3. [Bảng map field → yêu cầu đề bài](#3-bảng-map-field--yêu-cầu-đề-bài)
4. [API cho từng tính năng Lab2](#4-api-cho-từng-tính-năng-lab2)
5. [Chi tiết object Work](#5-chi-tiết-object-work)
6. [Xử lý Abstract](#6-xử-lý-abstract)
7. [Aggregate trên app (Trend / Top / Dashboard)](#7-aggregate-trên-app-trend--top--dashboard)
8. [Dùng group_by (tùy chọn)](#8-dùng-group_by-tùy-chọn)
9. [Phân trang](#9-phân-trang)
10. [Code mẫu Flutter/Dart](#10-code-mẫu-flutterdart)
11. [Xử lý lỗi & lưu ý thực tế](#11-xử-lý-lỗi--lưu-ý-thực-tế)
12. [Cheat sheet – copy URL nhanh](#12-cheat-sheet--copy-url-nhanh)

---

## 1. Thông tin cơ bản

### Base URL

```
https://api.openalex.org
```

### Endpoint chính cho Lab2

| Endpoint | Mô tả |
|----------|-------|
| `GET /works` | Danh sách bài báo (search, filter, sort) |
| `GET /works/{id}` | Chi tiết 1 bài báo |

Lab2 **chỉ cần `/works`** là đủ 100% yêu cầu.

### Authentication

Thêm API key vào query (free, đăng ký tại [openalex.org/settings/api](https://openalex.org/settings/api)):

```
?api_key=YOUR_KEY
```

Mỗi ngày có **$1 credit miễn phí** — đủ cho lab (~10.000 list requests/ngày). Chi tiết: [Authentication & Pricing](https://developers.openalex.org/guides/authentication).

### mailto (nên có)

Thêm email để vào "polite pool" (request ổn định hơn):

```
&mailto=your.email@fpt.edu.vn
```

### URL đầy đủ mẫu

```
https://api.openalex.org/works?search=machine+learning&per_page=25&sort=cited_by_count:desc&api_key=YOUR_KEY&mailto=your@email.com
```

### Method & Headers

```
GET
Accept: application/json
```

Không cần body. Flutter dùng package `http` hoặc `dio`.

---

## 2. Cấu trúc response

Mọi endpoint list (`/works`) trả về cùng format:

```json
{
  "meta": {
    "count": 2716667,
    "db_response_time_ms": 1059,
    "page": 1,
    "per_page": 25,
    "groups_count": null
  },
  "results": [
    { "id": "https://openalex.org/W2122410182", "title": "...", ... }
  ],
  "group_by": []
}
```

| Field | Ý nghĩa | Dùng cho |
|-------|---------|----------|
| `meta.count` | Tổng số bài khớp query | Dashboard: total publications |
| `meta.page` | Trang hiện tại | Pagination |
| `meta.per_page` | Số bài mỗi trang | Pagination |
| `results` | Mảng bài báo | Search, Detail, Aggregate |
| `group_by` | Kết quả gom nhóm (khi dùng `group_by=`) | Trend (tùy chọn) |

Endpoint singleton (`/works/W123`) trả về **1 object Work trực tiếp**, không có `meta`/`results`.

---

## 3. Bảng map field → yêu cầu đề bài

| Yêu cầu đề (FR) | Field JSON trong Work | Ghi chú |
|-----------------|----------------------|---------|
| **4.1** Title | `title` | Luôn có |
| **4.1** Publication year | `publication_year` | int, vd: `2023` |
| **4.1** Citation count | `cited_by_count` | int |
| **4.1** Journal name | `primary_location.source.display_name` | Có thể null → fallback |
| **4.2** Authors | `authorships[].author.display_name` | Mảng, nhiều tác giả |
| **4.2** DOI | `doi` hoặc `ids.doi` | Có thể null |
| **4.2** Abstract | `abstract_inverted_index` | Cần decode, có thể null |
| **4.3** Trend theo năm | `publication_year` (gom count) | Aggregate client-side |
| **4.4** Top papers | `cited_by_count` + `sort` | Sort desc từ API |
| **4.5** Top journals | `primary_location.source.display_name` | Đếm frequency |
| **4.6** Top authors | `authorships[].author.display_name` | Đếm frequency |
| **4.7** Total publications | `meta.count` | Từ response search |
| **4.7** Avg citation | Trung bình `cited_by_count` | Tính trên sample |
| **4.7** Most active year | Năm có count max | Từ trend aggregate |
| **4.7** Top journal / author / paper | Max từ aggregate | Tính trên sample |

---

## 4. API cho từng tính năng Lab2

### 4.1 Topic Search – Tìm bài theo chủ đề

**Mục đích:** User gõ topic → hiện list bài (title, year, citation, journal).

**Request:**

```http
GET /works?search={TOPIC}&per_page=25&page=1&api_key={KEY}&mailto={EMAIL}
```

**Ví dụ thật (đã test OK):**

```
https://api.openalex.org/works?search=artificial+intelligence&per_page=25&mailto=test@example.com
```

→ Trả về `meta.count = 2,716,667` bài, mỗi item có đủ 4 field cần hiển thị.

**Topic gợi ý demo:**

| Topic | URL encode |
|-------|------------|
| Artificial Intelligence | `artificial+intelligence` |
| Machine Learning | `machine+learning` |
| Cybersecurity | `cybersecurity` |
| Blockchain | `blockchain` |
| IoT | `internet+of+things` |
| Data Science | `data+science` |

**Search nâng cao (tùy chọn):**

```http
# Tìm chính xác cụm từ
?search="deep learning"

# AND / OR / NOT
?search=(blockchain AND security) NOT survey

# Lọc thêm năm
?search=machine+learning&filter=publication_year:2020-2024
```

Docs: [Searching](https://developers.openalex.org/guides/searching)

---

### 4.2 Publication Detail – Chi tiết 1 bài

**Cách 1 – Dùng data từ list (khuyên dùng):**  
Khi user tap 1 item trong search, object `Work` trong `results` **đã có đủ field** cho màn Detail. Không cần gọi thêm API.

**Cách 2 – Fetch riêng by ID:**

```http
GET /works/{WORK_ID}?api_key={KEY}&mailto={EMAIL}
```

**Ví dụ:**

```
https://api.openalex.org/works/W2122410182?mailto=test@example.com
```

**Cách 3 – Fetch by DOI:**

```
https://api.openalex.org/works/doi:10.1016/0004-3702(96)00007-0
```

Docs: [Get Singleton](https://developers.openalex.org/guides/get)

---

### 4.3 Publication Trend – Xu hướng theo năm

**Cách khuyên dùng – Aggregate trên app:**

```http
GET /works?search={TOPIC}&per_page=100&sort=publication_date:desc&filter=publication_year:2015-2024
```

Lấy 50–100 bài → đếm số bài theo `publication_year` → vẽ chart.

**Pseudo logic:**

```
yearCount = {}
for work in results:
    yearCount[work.publication_year] += 1
→ [{year: 2020, count: 15}, {year: 2021, count: 22}, ...]
```

**Cách 2 – group_by phía server (xem mục 8):**

```http
GET /works?search={TOPIC}&filter=publication_year:2015-2024&group_by=publication_year
```

> ⚠️ `group_by` với topic quá rộng có thể timeout. Luôn thêm `filter` thu hẹp phạm vi.

---

### 4.4 Top Influential Papers – Bài nhiều citation nhất

**Request:**

```http
GET /works?search={TOPIC}&sort=cited_by_count:desc&per_page=10&api_key={KEY}&mailto={EMAIL}
```

**Ví dụ thật (đã test OK):**

```
https://api.openalex.org/works?search=cybersecurity&sort=cited_by_count:desc&per_page=10&mailto=test@example.com
```

Kết quả mẫu:

| # | Citations | Title | Year |
|---|-----------|-------|------|
| 1 | 8,301 | Internet of Things: A Survey... | 2015 |
| 2 | 7,511 | Review of deep learning... | 2021 |
| 3 | 6,860 | Massive MIMO... | 2014 |

API đã sort sẵn → hiển thị trực tiếp, không cần sort lại.

---

### 4.5 Top Research Journals – Tạp chí xuất bản nhiều nhất

**Không có endpoint riêng.** Lấy sample rồi đếm:

```http
GET /works?search={TOPIC}&per_page=100&sort=cited_by_count:desc
```

**Logic:**

```dart
// Đếm frequency của journal name
journalCount[work.primaryLocation?.source?.displayName ?? 'Unknown']++;
// Sort desc → top journals
```

**group_by (tùy chọn):**

```http
GET /works?search={TOPIC}&filter=publication_year:2023&group_by=primary_location.source.id&per_page=10
```

Response `group_by[].key_display_name` = tên journal, `count` = số bài.

---

### 4.6 Top Contributing Authors – Tác giả viết nhiều nhất

**Logic client-side:**

```http
GET /works?search={TOPIC}&per_page=100
```

```dart
for (work in works) {
  for (authorship in work.authorships) {
    authorCount[authorship.author.displayName]++;
  }
}
```

**group_by (tùy chọn):**

```http
GET /works?search={TOPIC}&filter=publication_year:2023&group_by=authorships.author.id&per_page=20
```

---

### 4.7 Research Dashboard – Tổng hợp 6 chỉ số

**Chỉ cần 1 request search + aggregate:**

```http
GET /works?search={TOPIC}&sort=cited_by_count:desc&per_page=100&api_key={KEY}&mailto={EMAIL}
```

| Chỉ số Dashboard | Cách lấy |
|------------------|----------|
| Total publications | `meta.count` |
| Average citation count | `sum(cited_by_count) / results.length` |
| Most active year | Năm có count cao nhất (từ trend) |
| Top journal | Journal name frequency cao nhất |
| Top author | Author name frequency cao nhất |
| Most influential paper | `results[0]` nếu đã sort `cited_by_count:desc` |

**Flow tối ưu – 1 API call phục vụ nhiều màn:**

```
searchWorks(topic, perPage: 100, sort: cited_by_count:desc)
    │
    ├─► Search Screen     → results (list)
    ├─► Detail Screen     → tap 1 item từ results
    ├─► Trend Screen      → aggregate publication_year
    ├─► Top Papers        → results đã sort (top 10)
    ├─► Top Journals      → aggregate source.display_name
    ├─► Top Authors       → aggregate authorships
    └─► Dashboard         → meta.count + các aggregate trên
```

---

## 5. Chi tiết object Work

Cấu trúc rút gọn các field quan trọng:

```json
{
  "id": "https://openalex.org/W2122410182",
  "doi": "https://doi.org/10.5860/choice.33-1577",
  "title": "Artificial intelligence: a modern approach",
  "publication_year": 1995,
  "publication_date": "1995-11-01",
  "cited_by_count": 22246,
  "type": "article",
  "primary_location": {
    "source": {
      "id": "https://openalex.org/S2764375719",
      "display_name": "Choice Reviews Online",
      "type": "journal",
      "issn_l": "0009-4978"
    }
  },
  "authorships": [
    {
      "author_position": "first",
      "author": {
        "id": "https://openalex.org/A5091863316",
        "display_name": "Nils J. Nilsson",
        "orcid": null
      }
    }
  ],
  "abstract_inverted_index": {
    "The": [0],
    "long-anticipated": [1],
    "revision": [2]
  },
  "open_access": {
    "is_oa": true,
    "oa_status": "green"
  },
  "ids": {
    "openalex": "https://openalex.org/W2122410182",
    "doi": "https://doi.org/10.5860/choice.33-1577"
  }
}
```

### Helper lấy Work ID ngắn

```dart
// "https://openalex.org/W2122410182" → "W2122410182"
String getWorkId(String fullId) => fullId.split('/').last;
```

### Helper lấy journal name an toàn

```dart
String getJournalName(Map<String, dynamic> work) {
  return work['primary_location']?['source']?['display_name']
      ?? 'Unknown Journal';
}
```

### Helper lấy danh sách tác giả

```dart
List<String> getAuthors(Map<String, dynamic> work) {
  final authorships = work['authorships'] as List? ?? [];
  return authorships
      .map((a) => a['author']?['display_name'] as String?)
      .whereType<String>()
      .toList();
}
```

---

## 6. Xử lý Abstract

OpenAlex **không trả abstract dạng text thuần**. Thay vào đó dùng `abstract_inverted_index`:

```json
{
  "abstract_inverted_index": {
    "The": [0],
    "long-anticipated": [1],
    "revision": [2],
    "of": [3]
  }
}
```

Key = từ, Value = vị trí trong câu.

### Hàm decode (Dart)

```dart
String? reconstructAbstract(Map<String, dynamic>? invertedIndex) {
  if (invertedIndex == null || invertedIndex.isEmpty) return null;

  // Tìm độ dài câu
  int maxIndex = 0;
  for (final positions in invertedIndex.values) {
    for (final pos in positions as List) {
      if (pos > maxIndex) maxIndex = pos;
    }
  }

  final words = List<String>.filled(maxIndex + 1, '');
  invertedIndex.forEach((word, positions) {
    for (final pos in positions as List) {
      words[pos] = word;
    }
  });

  return words.join(' ');
}
```

**Lưu ý:** Không phải bài nào cũng có abstract (`null` ~30–40% bài). Hiển thị: *"Abstract not available"*.

---

## 7. Aggregate trên app (Trend / Top / Dashboard)

Đây là **cách làm chính và ổn định nhất** cho Lab2.

### 7.1 Trend theo năm

```dart
class YearTrend {
  final int year;
  final int count;
  YearTrend(this.year, this.count);
}

List<YearTrend> computeYearTrend(List<Map<String, dynamic>> works) {
  final counts = <int, int>{};
  for (final w in works) {
    final year = w['publication_year'] as int?;
    if (year != null) counts[year] = (counts[year] ?? 0) + 1;
  }
  return counts.entries
      .map((e) => YearTrend(e.key, e.value))
      .toList()
    ..sort((a, b) => a.year.compareTo(b.year));
}
```

### 7.2 Top Journals

```dart
class RankedItem {
  final String name;
  final int count;
  RankedItem(this.name, this.count);
}

List<RankedItem> computeTopJournals(List<Map<String, dynamic>> works, {int limit = 10}) {
  final counts = <String, int>{};
  for (final w in works) {
    final name = w['primary_location']?['source']?['display_name'] as String?
        ?? 'Unknown Journal';
    counts[name] = (counts[name] ?? 0) + 1;
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(limit).map((e) => RankedItem(e.key, e.value)).toList();
}
```

### 7.3 Top Authors

```dart
List<RankedItem> computeTopAuthors(List<Map<String, dynamic>> works, {int limit = 10}) {
  final counts = <String, int>{};
  for (final w in works) {
    final authorships = w['authorships'] as List? ?? [];
    for (final a in authorships) {
      final name = a['author']?['display_name'] as String?;
      if (name != null && name.isNotEmpty) {
        counts[name] = (counts[name] ?? 0) + 1;
      }
    }
  }
  final sorted = counts.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  return sorted.take(limit).map((e) => RankedItem(e.key, e.value)).toList();
}
```

### 7.4 Dashboard Summary

```dart
class DashboardSummary {
  final int totalPublications;      // meta.count
  final double averageCitations;
  final int? mostActiveYear;
  final String? topJournal;
  final String? topAuthor;
  final String? mostInfluentialPaper;
  final int? mostInfluentialCitations;

  DashboardSummary({...});
}

DashboardSummary computeDashboard({
  required int metaCount,
  required List<Map<String, dynamic>> works,
}) {
  if (works.isEmpty) {
    return DashboardSummary(totalPublications: metaCount, averageCitations: 0, ...);
  }

  final avgCite = works
      .map((w) => (w['cited_by_count'] as int?) ?? 0)
      .reduce((a, b) => a + b) / works.length;

  final yearTrend = computeYearTrend(works);
  final mostActive = yearTrend.isEmpty
      ? null
      : yearTrend.reduce((a, b) => a.count >= b.count ? a : b).year;

  final topJournals = computeTopJournals(works, limit: 1);
  final topAuthors = computeTopAuthors(works, limit: 1);

  final topPaper = works.first; // nếu đã sort cited_by_count:desc

  return DashboardSummary(
    totalPublications: metaCount,
    averageCitations: avgCite,
    mostActiveYear: mostActive,
    topJournal: topJournals.isNotEmpty ? topJournals.first.name : null,
    topAuthor: topAuthors.isNotEmpty ? topAuthors.first.name : null,
    mostInfluentialPaper: topPaper['title'] as String?,
    mostInfluentialCitations: topPaper['cited_by_count'] as int?,
  );
}
```

---

## 8. Dùng group_by (tùy chọn)

API có thể gom nhóm phía server thay vì tự đếm trên app.

**Request:**

```http
GET /works?search={TOPIC}&filter=publication_year:2020-2024&group_by=publication_year&per_page=200&cursor=*
```

**Response:**

```json
{
  "meta": { "count": 50000, "groups_count": 5 },
  "group_by": [
    { "key": "2020", "key_display_name": "2020", "count": 8500 },
    { "key": "2021", "key_display_name": "2021", "count": 10200 }
  ],
  "results": []
}
```

### Các group_by hữu ích cho Lab2

| Mục đích | group_by value |
|----------|----------------|
| Trend theo năm | `publication_year` |
| Top journals | `primary_location.source.id` |
| Top authors | `authorships.author.id` |
| Phân loại bài | `type` |

### Lưu ý quan trọng (từ test thực tế)

| Vấn đề | Giải pháp |
|--------|-----------|
| Topic quá rộng → timeout / lỗi 503 | Luôn thêm `filter=publication_year:YYYY-YYYY` |
| `group_by` không sort theo count | Sort lại trên app nếu cần |
| Pagination group_by dùng `cursor=*` | Không dùng `page=2` |
| Kết quả không chính xác 100% với sample nhỏ | Dùng `meta.count` cho total, sample cho top/trend |

**Khuyến nghị Lab2:** Dùng **client-side aggregate** (mục 7) — đơn giản, ổn định, dễ demo.

---

## 9. Phân trang

### Cách 1 – page/per_page (đơn giản)

```http
GET /works?search=blockchain&per_page=25&page=1
GET /works?search=blockchain&per_page=25&page=2
```

- `per_page`: 1–100 (default 25)
- `page`: số trang (bắt đầu từ 1)

### Cách 2 – cursor (deep pagination)

```http
GET /works?search=blockchain&per_page=100&cursor=*
# Response có meta.next_cursor → dùng cho request tiếp
GET /works?search=blockchain&per_page=100&cursor={next_cursor}
```

Lab2 thường chỉ cần **page 1, per_page=50~100** là đủ.

---

## 10. Code mẫu Flutter/Dart

### 10.1 Dependencies (pubspec.yaml)

```yaml
dependencies:
  http: ^1.2.0
  provider: ^6.1.0        # hoặc riverpod / bloc
  fl_chart: ^0.69.0       # vẽ biểu đồ
  flutter_dotenv: ^5.2.0  # lưu API key (không hard-code)
```

### 10.2 OpenAlexService hoàn chỉnh

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class OpenAlexService {
  static const _baseUrl = 'https://api.openalex.org';
  final String apiKey;
  final String mailto;

  OpenAlexService({required this.apiKey, required this.mailto});

  /// Tìm kiếm bài báo theo topic — API chính cho toàn bộ app
  Future<SearchResult> searchWorks({
    required String topic,
    int perPage = 50,
    int page = 1,
    String sort = 'cited_by_count:desc',
    String? yearFilter, // vd: "2020-2024"
  }) async {
    final params = {
      'search': topic,
      'per_page': '$perPage',
      'page': '$page',
      'sort': sort,
      'mailto': mailto,
      'api_key': apiKey,
    };
    if (yearFilter != null) {
      params['filter'] = 'publication_year:$yearFilter';
    }

    final uri = Uri.parse('$_baseUrl/works').replace(queryParameters: params);
    final response = await http.get(uri);

    if (response.statusCode != 200) {
      throw OpenAlexException('HTTP ${response.statusCode}: ${response.body}');
    }

    final json = jsonDecode(response.body) as Map<String, dynamic>;
    final meta = json['meta'] as Map<String, dynamic>;
    final results = (json['results'] as List)
        .cast<Map<String, dynamic>>();

    return SearchResult(
      totalCount: meta['count'] as int,
      works: results,
    );
  }

  /// Lấy chi tiết 1 bài by OpenAlex ID
  Future<Map<String, dynamic>> getWorkById(String workId) async {
    final id = workId.contains('/') ? workId.split('/').last : workId;
    final uri = Uri.parse('$_baseUrl/works/$id').replace(queryParameters: {
      'mailto': mailto,
      'api_key': apiKey,
    });
    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw OpenAlexException('HTTP ${response.statusCode}');
    }
    return jsonDecode(response.body) as Map<String, dynamic>;
  }
}

class SearchResult {
  final int totalCount;
  final List<Map<String, dynamic>> works;
  SearchResult({required this.totalCount, required this.works});
}

class OpenAlexException implements Exception {
  final String message;
  OpenAlexException(this.message);
  @override
  String toString() => message;
}
```

### 10.3 Model Work (typed)

```dart
class Work {
  final String id;
  final String? title;
  final int? publicationYear;
  final int citedByCount;
  final String? journalName;
  final List<String> authors;
  final String? doi;
  final String? abstract;

  Work({
    required this.id,
    this.title,
    this.publicationYear,
    required this.citedByCount,
    this.journalName,
    required this.authors,
    this.doi,
    this.abstract,
  });

  factory Work.fromJson(Map<String, dynamic> json) {
    return Work(
      id: json['id'] as String,
      title: json['title'] as String?,
      publicationYear: json['publication_year'] as int?,
      citedByCount: json['cited_by_count'] as int? ?? 0,
      journalName: json['primary_location']?['source']?['display_name'] as String?,
      authors: (json['authorships'] as List? ?? [])
          .map((a) => a['author']?['display_name'] as String?)
          .whereType<String>()
          .toList(),
      doi: json['doi'] as String?,
      abstract: reconstructAbstract(
        json['abstract_inverted_index'] as Map<String, dynamic>?,
      ),
    );
  }
}
```

### 10.4 Gọi từ Provider

```dart
class SearchProvider extends ChangeNotifier {
  final OpenAlexService _service;
  SearchProvider(this._service);

  bool isLoading = false;
  String? error;
  SearchResult? result;
  List<YearTrend> yearTrend = [];
  List<RankedItem> topJournals = [];
  List<RankedItem> topAuthors = [];
  DashboardSummary? dashboard;

  Future<void> search(String topic) async {
    isLoading = true;
    error = null;
    notifyListeners();

    try {
      result = await _service.searchWorks(
        topic: topic,
        perPage: 100,
        sort: 'cited_by_count:desc',
        yearFilter: '2015-2024',
      );
      final works = result!.works;
      yearTrend = computeYearTrend(works);
      topJournals = computeTopJournals(works);
      topAuthors = computeTopAuthors(works);
      dashboard = computeDashboard(
        metaCount: result!.totalCount,
        works: works,
      );
    } on OpenAlexException catch (e) {
      error = e.message;
    } catch (e) {
      error = 'Network error: $e';
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
```

---

## 11. Xử lý lỗi & lưu ý thực tế

### HTTP status codes

| Code | Ý nghĩa | Xử lý trong app |
|------|---------|-----------------|
| 200 | OK | Parse JSON |
| 301 | Redirect (merged ID) | http client tự follow |
| 400 | Bad request (URL quá dài…) | Hiện lỗi, rút gọn query |
| 403 | API key invalid | Kiểm tra key |
| 404 | Work không tồn tại | Hiện "Not found" |
| 429 | Rate limit | Retry sau vài giây |
| 503 | Server timeout | Retry + giảm per_page |

### Best practices cho Lab2

1. **Không hard-code API key** — dùng `.env` hoặc `--dart-define`
2. **Debounce search** — đợi user ngừng gõ 500ms mới gọi API
3. **per_page=50~100** — đủ cho trend/top, tránh timeout
4. **Thêm filter năm** — kết quả relevant hơn, request nhanh hơn
5. **Cache kết quả topic** — đổi tab Dashboard/Trend không gọi lại API
6. **Loading + empty state** — topic không có kết quả vẫn hiện UI rõ ràng
7. **Fallback null** — journal/abstract/DOI có thể thiếu

### Giới hạn cần biết

| Giới hạn | Giá trị |
|----------|---------|
| per_page max | 100 |
| URL max length | ~4 KB |
| group_by max groups/page | 200 |
| Free daily credit | $1 (~10K list calls) |

### Test nhanh bằng curl (Windows)

```powershell
curl.exe -s "https://api.openalex.org/works?search=cybersecurity&sort=cited_by_count:desc&per_page=5&mailto=your@email.com"
```

---

## 12. Cheat sheet – copy URL nhanh

Thay `{TOPIC}`, `{KEY}`, `{EMAIL}` rồi paste vào browser hoặc Postman.

### Search cơ bản
```
https://api.openalex.org/works?search={TOPIC}&per_page=25&api_key={KEY}&mailto={EMAIL}
```

### Search + sort top cited (Top Papers + Dashboard)
```
https://api.openalex.org/works?search={TOPIC}&sort=cited_by_count:desc&per_page=50&api_key={KEY}&mailto={EMAIL}
```

### Search + lọc 10 năm gần nhất (Trend)
```
https://api.openalex.org/works?search={TOPIC}&filter=publication_year:2015-2024&sort=publication_date:desc&per_page=100&api_key={KEY}&mailto={EMAIL}
```

### Chi tiết 1 bài
```
https://api.openalex.org/works/W2122410182?api_key={KEY}&mailto={EMAIL}
```

### Trend bằng group_by (thử, có thể chậm)
```
https://api.openalex.org/works?search={TOPIC}&filter=publication_year:2020-2024&group_by=publication_year&api_key={KEY}&mailto={EMAIL}
```

### Top journals bằng group_by
```
https://api.openalex.org/works?search={TOPIC}&filter=publication_year:2023&group_by=primary_location.source.id&per_page=10&api_key={KEY}&mailto={EMAIL}
```

### Top authors bằng group_by
```
https://api.openalex.org/works?search={TOPIC}&filter=publication_year:2023&group_by=authorships.author.id&per_page=10&api_key={KEY}&mailto={EMAIL}
```

---

## Tóm tắt 1 dòng

> **Lab2 chỉ cần 1 API chính:** `GET /works?search={topic}&sort=cited_by_count:desc&per_page=100` → lấy `meta.count` + `results` → từ `results` suy ra Search, Detail, Trend, Top Papers/Journals/Authors, Dashboard.

---

## Tài liệu tham khảo

- [API Overview](https://developers.openalex.org/api-reference/introduction)
- [Searching](https://developers.openalex.org/guides/searching)
- [Filtering](https://developers.openalex.org/guides/filtering)
- [Grouping](https://developers.openalex.org/guides/grouping)
- [Get Singleton](https://developers.openalex.org/guides/get)
- [Authentication & Pricing](https://developers.openalex.org/guides/authentication)
- [LLM Reference (full index)](https://developers.openalex.org/llms.txt)
