#10월 28일 전 종목 주가 크롤링

#27일에 짠 코드에서 for loop 구문을 써서 i값만 변경해주면 모든 종목의
#주가를 다운로드 할 수 있다. 전종목 주가를 크롤링하는 방법은 다음과 같다.

library(httr)
library(rvest)
library(stringr)
library(xts)
library(lubridate)
library(readr)

setwd("C:/Users/user/Desktop/new/data")

KOR_ticker <- read.csv('KOR_ticker.csv', row.names = 1)
print(KOR_ticker$종목코드[1])


for (i in 1 : nrow(KOR_ticker)) {
  price = xts(NA, order.by = Sys.Date()) #빈 시계열 데이터 생성
  name = KOR_ticker$종목코드[i] #티커 부분 선택
  
  #오류 발생시 이를 무시하고 다음 루프로 진행
  tryCatch({
    #URL생성
    url = paste0(
      'https://fchart.stock.naver.com/sise.nhn?symbol=005930&timeframe=day&count=500&requestType=0')
    data = GET(url)
    data_html <- read_html(data, encoding = 'EUC-KR') %>% 
      html_nodes("item") %>% 
      html_attr("data")
    
    #데이터 나누기
    price <- read_delim(data_html, delim = '|')
    
    #필요한 열만 선택 후 클렌징
    
    price <- price[c(1, 5)]
    price <- data.frame(price)
    colnames(price) <- c('Date', 'Price')
    price[, 1] = ymd(price[, 1])
    
    rownames(price) = price[, 1]
    price[, 1] = NULL
    
  }, error = function(e) {
    
    #오류 발생 시 해당 종목명을 출력하고 다음 루프로 이동
    warning(paste0("Error in Ticker:", name))
  })
  
  #다운로드한 파일을 생성한 폴더 내 csv파일로 저장
  write.csv(price, paste0("name", 'all_price.csv'))
  
  #타임슬립 적용
  Sys.sleep(2)
}
