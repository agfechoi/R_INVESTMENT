#10월 23일 미리 예습 ㅎㅎ 최근 영업일 기준 데이터 받기

#22일에 한거 기준으로 query 항목중에 date와 schdate 부분을 원하는 일자로 입력하면
#해당일의 데이터를 다운로드 할 수 있다. 하지만 매번 이런식으로 하는 것은 귀찮은 일이므로
# 자동으로 하게해보자

library(httr)
library(rvest)
library(stringr)
library(readr)
#네이버 금융의 [국내 증시 --> 증시자금동향 pg]
url = 'https://finance.naver.com/sise/sise_deposit.nhn' #페이지의 url 저장

biz_day = GET(url) %>% #get함수로 해당 url의 내용을 받는다.
  read_html(encoding = 'EUC-KR') %>% #read_html로 html을 읽고 euc-kr로 인코딩해온다.
  html_nodes(xpath = 
               '//*[@id="type_0"]/div/ul[2]/li/span') %>% #html_nodes함수로 #복사해온
  #Xpath를 입력해서 해당 지점의 데이터만 추출한다.
  html_text() %>%  #해당 html의 text만 추출
  str_match(('[0-9]+.[0-9]+.[0-9]+')) %>% #str_match함수에서 정규표현식을 사용해서
  #숫자.숫자.숫자형식의 데이터를 추출한다. 홈페이지에보면 2020.10.20 일케 되잇다.
  str_replace_all('\\.', '') #str_replace_all함수를 써서 마침표를 모두 없앤다.

biz_day #최근 영업일 기준을 뽑아온다.

gen_otp_url = 
  'http://marketdata.krx.co.kr/contents/COM/GenerateOTP.jspx'
gen_otp_data = list(
  name = 'filedown',
  filetype = 'csv',
  url = 'MKD/13/1302/13020401/mkd13020401',
  market_gubun = 'ALL',
  gubun = '1',
  schdate = biz_day, #위에서 크롤링해온 최근 영업일로 변경
  pagePath = '/contents/MKD/13/1302/13020401/MKD13020401.jsp'
)

otp = POST(gen_otp_url, query = gen_otp_data) %>% 
  read_html() %>% 
  html_text()

down_url <- 'http://file.krx.co.kr/download.jspx'
down_ind <- POST(down_url, query = list(code = otp),
                 add_headers(referer = gen_otp_url)) %>% 
  read_html() %>% 
  html_text() %>% 
  read_csv()

getwd()
setwd("C:/Rinv")
ifelse(dir.exists('data'), FALSE, dir.create('data'))
write.csv(down_ind, 'data/krx_ind.csv')

#이렇게 받아온 데이터는 중복된 열이 있고, 불필요한 데이터들도 있다.
#따라서 하나의 테이블로 합친 후 정리할 필요가 있다.
# 전처리 과정은 24일에 하는걸로 한다.