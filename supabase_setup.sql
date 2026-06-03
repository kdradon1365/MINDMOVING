-- ============================================================
-- 마인드무빙 컨설팅 홈페이지 Supabase 초기 설정
-- Supabase 대시보드 → SQL Editor 에서 실행하세요
-- ============================================================

-- 0. 강의 이력 (localStorage 완전 대체)
create table if not exists lectures (
  id           text primary key,
  title        text not null,
  organization text not null,
  date         text not null,
  category     text,
  note         text,
  photo_url    text,
  created_at   timestamptz default now()
);

alter table lectures enable row level security;
drop policy if exists "public read"   on lectures;
drop policy if exists "anon insert"   on lectures;
drop policy if exists "anon update"   on lectures;
drop policy if exists "anon delete"   on lectures;
create policy "public read" on lectures for select using (true);
create policy "anon insert" on lectures for insert with check (true);
create policy "anon update" on lectures for update using (true);
create policy "anon delete" on lectures for delete using (true);

-- 1. 사이트 텍스트 콘텐츠 (key-value)
create table if not exists site_content (
  key   text primary key,
  value text not null
);

-- 2. 강의 분야
create table if not exists lecture_areas (
  id         serial primary key,
  icon       text not null,
  title      text not null,
  sort_order int  not null default 0,
  active     boolean not null default true
);

-- 3. 출강 기관
create table if not exists about_orgs (
  id         serial primary key,
  badge      text not null default '현)',
  name       text not null,
  sort_order int  not null default 0,
  active     boolean not null default true
);

-- 4. 강의 키워드 태그
create table if not exists about_tags (
  id         serial primary key,
  label      text not null,
  sort_order int  not null default 0
);

-- ============================================================
-- RLS 활성화 + 퍼블릭 읽기 허용
-- ============================================================
alter table site_content  enable row level security;
alter table lecture_areas enable row level security;
alter table about_orgs    enable row level security;
alter table about_tags    enable row level security;

drop policy if exists "public read" on site_content;
drop policy if exists "public read" on lecture_areas;
drop policy if exists "public read" on about_orgs;
drop policy if exists "public read" on about_tags;

create policy "public read" on site_content  for select using (true);
create policy "public read" on lecture_areas for select using (true);
create policy "public read" on about_orgs    for select using (true);
create policy "public read" on about_tags    for select using (true);

-- ============================================================
-- 초기 데이터 삽입
-- ============================================================

-- 사이트 텍스트
insert into site_content (key, value) values
  ('hero_title',    '마인드무빙 컨설팅'),
  ('hero_desc',     '현장을 이해하는 교육,<br>사람을 움직이는 경험,<br>조직을 바꾸는 변화.'),
  ('about_name',    '김해용'),
  ('about_role',    '마인드무빙 컨설팅 대표'),
  ('about_text1',   'Roll-Play(롤플레이) 기반의 체험 중심 교육으로 수많은 공공기관과 기업 교육기관에서 강의를 진행하고 있습니다.'),
  ('about_text2',   '이론이 아닌 현장에서 검증된 방식으로 참여자 스스로 변화를 체험하고, 조직과 개인의 실질적인 성장을 이루도록 돕습니다.'),
  ('contact_desc',  '강의 및 컨설팅 관련 문의는 언제든지 편하게 연락 주세요.'),
  ('contact_email', '2haeyong@naver.com'),
  ('contact_phone', '010-5468-9215'),
  ('company_name',  '마인드무빙 컨설팅'),
  ('company_rep',   '김해용')
on conflict (key) do update set value = excluded.value;

-- 강의 분야
insert into lecture_areas (icon, title, sort_order) values
  ('🏆', '리더십 / 조직문화',              1),
  ('💬', '커뮤니케이션 및 갈등관리 / 협상', 2),
  ('🧠', '심리 / 멘탈 코칭',              3),
  ('📈', '세일즈 / 영업코칭 및 서비스',    4),
  ('📚', '기업교육 / HRD',                5),
  ('🎭', 'Roll-Play(롤플레이) 활용 강의',  6),
  ('🤝', '민원 응대',                     7),
  ('🎬', '연극 활용 기업교육',             8),
  ('🌿', '스트레스 감정관리 교육',         9),
  ('💪', '회복탄력성',                    10),
  ('🎯', '핵심가치 내재화 교육',          11);

-- 출강 기관
insert into about_orgs (badge, name, sort_order) values
  ('현)', '병무청 사회복무연수센터', 1),
  ('현)', '지방공기업평가원',       2),
  ('현)', '인천 소방학교',         3),
  ('현)', '경북 소방학교',         4),
  ('현)', '서울 소방학교',         5);

-- 강의 키워드 태그
insert into about_tags (label, sort_order) values
  ('Roll-Play(롤플레이)', 1),
  ('기업교육',            2),
  ('리더십',             3),
  ('HRD',               4),
  ('감정관리',           5),
  ('회복탄력성',         6),
  ('커뮤니케이션',       7),
  ('팀빌딩',            8),
  ('조직 활성화',        9);

-- ============================================================
-- 강의 사진 업로드용 Storage 버킷 설정
-- (아직 실행하지 않은 경우 아래도 함께 실행하세요)
-- ============================================================

-- Storage 버킷 생성 (public)
insert into storage.buckets (id, name, public)
values ('lecture-photos', 'lecture-photos', true)
on conflict (id) do nothing;

-- 퍼블릭 읽기 허용
create policy "public read lecture photos" on storage.objects
for select using (bucket_id = 'lecture-photos');

-- 관리자(anon key)에서 업로드 허용
create policy "anon upload lecture photos" on storage.objects
for insert with check (bucket_id = 'lecture-photos');

-- 관리자(anon key)에서 삭제/교체 허용
create policy "anon update lecture photos" on storage.objects
for update using (bucket_id = 'lecture-photos');

create policy "anon delete lecture photos" on storage.objects
for delete using (bucket_id = 'lecture-photos');
