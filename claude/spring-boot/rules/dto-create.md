---
paths:
  - "src/main/**"
  - "src/test/**"
---

# DTO 작성 규칙

각 DTO 종류의 역할은 `dto-layer.md`를 따른다. 이 문서는 작성 방법이다. 코드는 형태를 보여주는 예시이며 도메인 이름은 바꿔 쓴다.

## Request (Controller 수신)

```java
@Getter
@NoArgsConstructor
public class ExcelJobCreateRequest {

    @NotBlank(message = "대상 테이블명은 필수입니다.")
    private String targetTable;

    @NotNull(message = "시작일은 필수입니다.")
    private LocalDate startDate;

    @Valid
    @NotEmpty
    private List<ItemRequest> items;   // 중첩 DTO는 별도 파일의 *Request, 필드에 @Valid가 있어야 내부 검증이 동작한다

    public ExcelJobCreateCommand toCommand() {
        return ExcelJobCreateCommand.builder()
            .targetTable(this.targetTable)
            .startDate(this.startDate)
            .build();
    }
}
```
- `@Getter` + `@NoArgsConstructor`. `@Setter` 금지.
- Controller에서 `@RequestBody @Valid`로 받는다. 쿼리 파라미터 객체는 `@Valid`로 받고, 단일 파라미터 검증은 Controller 클래스에 `@Validated`를 둔다.
- Bean Validation은 Request에만 둔다. 업무 규칙 검증(중복, 상태 전이 등)은 Service에서 예외로 처리한다(`validation.md`).
- `toCommand()`로 Command를 만든다. Request가 Command를 import하는 방향은 허용한다. 반대인 `Command.from(Request)`는 금지한다(Service가 HTTP 계층을 알게 된다).
- Entity, Command를 필드로 갖지 않는다.
- 테스트에서 Request 만들기: `<<결정>>`. 기본은 JSON 문자열을 `ObjectMapper`로 역직렬화하거나 MockMvc 요청 본문으로 보낸다. 테스트를 위해 setter를 열지 않는다.

## Command (Service 데이터 변경 요청)

```java
@Getter
@Builder
public class ExcelJobCreateCommand {
    private final String targetTable;
    private final LocalDate startDate;
}
```
- `@Getter` + `@Builder`, 모든 필드 `final`.
- Validation 어노테이션 없음(Request에서 검증 완료).
- Controller: `excelJobService.create(request.toCommand());`

## Query (Service 데이터 조회 요청)

```java
@Getter
@Builder
public class OrderSearchQuery {
    private final String category;
    private final String status;
    private final LocalDate startDate;
    private final LocalDate endDate;
}
```
- `@Getter` + `@Builder`, 모든 필드 `final`.
- Request가 없는 쿼리 파라미터 조회는 Controller에서 직접 빌드한다.
- 단순 단건 ID 조회는 Query 없이 파라미터로 전달해도 된다.
- 페이지·정렬 조건은 Query에 담는다(`dto-layer.md`).

## Result

- `@Getter` + `@Builder`, 모든 필드 `final`. JOIN 조회 결과(비정규화 필드)도 담을 수 있다.
- 생성 방식은 설치된 `result-creation.md`를 따른다.
  - `service-converts`: `static from(Entity)` 팩토리를 Result 안에 둔다.
    ```java
    public static ExcelJobResult from(ExcelJob job) {
        return ExcelJobResult.builder().jobId(job.getId()).status(job.getStatus()).build();
    }
    ```
  - `query-repository`: 쿼리 프로젝션이 쓰는 생성 방식(생성자/`@QueryProjection` 등: `<<결정>>`)을 둔다. 엔티티를 통째로 필드에 담지 않는다.

## Response (API 응답)

```java
@Getter
@Builder
public class ExcelJobResponse {
    private final Long jobId;
    private final String status;

    public static ExcelJobResponse from(ExcelJobResult result) {
        return ExcelJobResponse.builder()
            .jobId(result.getJobId())
            .status(result.getStatus().name())
            .build();
    }
}
```
- `@Getter` + `@Builder`, 모든 필드 `final`.
- Result → Response 변환은 `Response.from(Result)` 정적 메서드.
- enum은 `.name()`으로 문자열 변환한다. 날짜/시간 형식: `<<결정>>`.
- Controller는 `ResponseEntity<CommonApiResponse<ExcelJobResponse>>`로 감싸 반환한다(`common-api-response.md`).
- 목록은 `List<*Response>` 또는 공통 페이지 응답에 담는다. null 대신 빈 목록.

## Entity (참고)
- `@Entity` + `@Getter`. setter 대신 의미 있는 메서드/정적 팩토리를 쓴다. 자세한 규칙은 `jpa-entity.md`.
- Controller 응답으로 직접 반환하지 않는다.

## 요약
| 항목 | 규칙 |
|---|---|
| Lombok (DTO) | `@Getter` + `@Builder` (Request는 `@Getter` + `@NoArgsConstructor`), `@Setter` 금지 |
| 불변성 | Command / Query / Result / Response 필드 `final` |
| Request → Command | `Request.toCommand()` |
| Query | Controller에서 직접 빌드 |
| Result → Response | `Response.from(Result)` |
| Entity 노출 | Controller·Response에서 직접 반환 금지 |
| Validation | Request에만 Bean Validation |
