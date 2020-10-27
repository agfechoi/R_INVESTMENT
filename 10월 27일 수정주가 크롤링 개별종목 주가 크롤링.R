#10월 27일 금융데이터 수집하기 수정주가 크롤링

#주가 데이터는 투자를 함에 있어서 반드시 필요한 데이터.
#인터넷을 통해 주가를 수집하는 방법은 많다.
#먼저 앞에서 했던 API를 이용해서 살펴본 방법
#이 경우 getSymbols()함수를 이용해 데이터를 받았음

#하지만 이건 야후 파이낸스에서 제공하는 데이터 중 미국 데이터는 괜찮지만
#국내 중소형 주식은 안나온다.

#그리고 단순 주가를 구할 수 있는 방법은 많지만, 투자에 필요한 수정주가를
#구할 수 있는 방법은 찾기 힘들다. 
#네이버 금융에서 제공하는 정보를 통해서 모든 종목의 수정주가를 손쉽게 구하기 가능

#개별종목 주가 크롤링

#네이버 금융에 접속해서 특정종목의 차트 탭을 선택, 해당 차트는 주가 데이터를 받아
#그래프를 그려주는 형태이다. 따라서 해당 데이터가 어디에서 오는지 알기 위해
#개발자 도구 화면을 이용한다. 개발자 도구 화면의 network탭을 본다.

#sise.nhn 항목의 Request URL이 주가 데이터를 요청하는 주소다.
#그 주소에 접속해보면 각 날자별로 시가, 고가, 저가, 종가, 거래량이 있고
#모든 주가는 수정주가 기준이다.
# 해당 데이터가 item 태그 내 data 속성에 위치하고 있다.

#URL에서 symbol = 뒤에 6자리 티커만 변경하면 해당 종목의 주가 데이터가 있는
#페이지로 이동 가능하다.

library(stringr)
getwd()
setwd("C:/Users/user/Desktop/new/data")
KOR_ticker <- read.csv("KOR_ticker.csv", row.names = 1)
print(KOR_ticker$종목코드[1])

#다음은 첫번째 종목인 삼성전자의 주가를 크롤링한 후 가공하는 방법이다.

library(xts)

ifelse(dir.exists('data/KOR_price'), FASLE,
       dir.create('data/KOR_price')) #data폴더 내에 KOR_price 폴더를 생성하는
#거라는데 안됀다 그래서 억지로 만들었다.

i = 1 #향후 for loop 구문을 통해 i값만 변경함녀 모든 종목의 주가를 다운로드 가능
name = KOR_ticker$종목코드[i] #name에 해당 티커를 입력한다.

price = xts(NA, order.by = Sys.Date()) #xts함수를 통해 빈 시계열 데이터를 생성,
#인덱스는 sys.date를 통해 현재 날자를 입력한다.
print(price)

library(httr)
library(rvest)

url = paste0("https://fchart.stock.naver.com/sise.nhn?symbol=005930&timeframe=day&count=500&requestType=0")
#paste0 함수를 이용해서 원하는 종목의 url을 생성한다 url 중 티커에 해당하는 
#6자리 부분만 위에서 입력한 name으로 설정해주면 된다.

data = GET(url) #get함수를 통해 페이지의 데이터를 불러온다.
data_html <- read_html(data, encoding = 'EUC-KR') %>% #read_html을 통해 html읽어옴
  html_nodes('item') %>% 
  html_attr('data') #html_nodes와 html_attr로 item태그, data 속성의 데이터를 추출

head(data_html)
#결과적으로 날짜, 주가, 거래량 데이터가 추출. 해당 데이터는 |로 구분되어 있어서
#이를 테이블 형태로 바꿀 필요가 있다.

library(readr)

price <- read_delim(data_html, delim = '|')
price
head(price)
tail(price)
#readr 패키지의 read_delim함수를 쓰면 구분자로 이루어진 데이터를 테이블로 쉽게 
#변경 가능. 데이터를 확인해보면 테이블 형태로 변경되어있음.
#각 열은 날짜, 시가, 고가, 저가, 종가, 거래량을 의미. 이중 우리가 필요한건
#날짜, 종가. 그러니까 나머지는 싹 날려보자

library(lubridate)
install.packages("timetk")
library(timetk)

price <- price[c(1, 5)] #날짜에 해당하는 첫 번째 열과, 종가에 해당하는 다섯 번째
#열만 선택해서 저장한다.
price <- data.frame(price) #데이터 프레임 형태로 변경한다.
colnames(price) <- c('Date', 'Price') #열이름을 Date, Price로 변경한다.
price[, 1] = ymd(price[, 1]) #lubridate의 ymd() 함수를 이용하면 yyyymmdd형태가
#yyyy-mm-dd로 변경되며 데이터 형태 또한 Date 타입으로 변경된다.
price <- tk_xts(price, data_var = Date) #timetk 패키지의 tk_xts()함수를 통해
#시계열 형태로 변경한다. 인덱스는 Date열로 설정. 형태를 변경한 후 해당 열은 
#자동으로 삭제된다.

#데이터를 확인하면 우리가 필요한 형태로 정리되었다.
#즉 삼성전자의 수정주가 데이터가 시계열로 날짜별로만 딱 정리되서 나왔다.
write.csv(price,'_price.csv')
