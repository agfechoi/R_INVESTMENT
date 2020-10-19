library(rvest)
library(httr)
#네이버 검색창에 종로구 사직동 맛집 검색
url = 'https://search.naver.com/search.naver?sm=top_hty&fbm=1&ie=utf8&query=%EC%A2%85%EB%A1%9C%EA%B5%AC+%EC%82%AC%EC%A7%81%EB%8F%99+%EB%A7%9B%EC%A7%91'
data = GET(url) #데이터라는 변수에 url을 get한걸 넣는다.

print(data) #상태를 보면 status가 200이어야 크롤링 가능

#음식점 제목들을 뽑아온다.
data_title = data %>% 
  read_html(encoding = 'UTF-8') %>% 
  html_nodes('body') %>% 
  html_nodes('.tit_inner') %>% 
  html_nodes('a') %>% 
  html_attr('title')

print(data_title)

#주소 긁어 오는 건데 대체 뭘 긁어오고 있니..
data_addr = data %>% 
  read_html(encoding = 'UTF-8') %>% 
  html_nodes('body') %>% 
  html_nodes('.addr') %>% 
  html_text()
print(data_addr)

#별점 긁어오기
data_rating = data %>% 
  read_html(encoding = 'UTF-8') %>% 
  html_nodes('body') %>% 
  html_nodes('.rating') %>% 
  html_text()

print(data_rating)

#

