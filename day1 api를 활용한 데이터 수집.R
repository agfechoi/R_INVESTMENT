getwd()
setwd("C:/Rinv")

install.packages("quantmod")
install.packages("PerformanceAnalytics")
install.packages("zoo")
install.packages("httr")
install.packages("rvest")

library(quantmod)
library(xts)
library(zoo)
library(httr)
library(rvest)

#url받아오는데 이 url누르면 csv파일 받아짐
url.aapl = "https://www.quandl.com/api/v3/datasets/WIKI/AAPL/data.csv?api_key=xw3NU3xLUZ7vZgrz5QnG"
#data.appl에 받은 csv열어서 넣는다.
data.aapl = read.csv(url.aapl)
#받아온 
head(data.aapl)
#getSymbols라는 함수를 쓰고 그 안에 애플의 티커(AAPL)를 입력한다 
library(quantmod) #getSymbols는 quantmod라는 패키지에서 따오는 것이다.
getSymbols('AAPL')
head(AAPL) #잘 가져왔나 확인
chart_Series(Ad(AAPL)) #시계열 데이터로 보는 함수인 챠트 시리즈를 놓고
#배당이 반영된 수정주가를 나타내라는 함수 Ad안에 티커를 넣는다.
#그러면 시계열 데이터가 나옴! 시계열 기간을 입력 안하면 2007년부터 현재까지
data = getSymbols('AAPL',
                  from = '2000-01-01', to = '2018-12-31',
                  auto.assign = FALSE)
head(data)
#from에 시작시점 입력 to에 종료시점 입력,, 해당기간 데이터가 다운로드됨

#getSymbols함수를 통해 받은 데이터는 자동으로 티커와 동일한 변수명에 
#저장된다. 만일 티커명이 아니라 따로 원하는 변수명이 있다면 
#auto.assign인자를 FALSE로 설정해주면 다운로드한 데이터가 원하는 변수에 저장됨

ticker = c('FB', 'NVDA')
getSymbols(ticker)
head(FB)
#페이스북, 엔비디아의 티커인 FB, NVDA를 ticker변수에 입력하고 getsymbols함수에
#티커를 입력한 변수를 넣으면 순차적으로 다운로드가 된다.

chart_Series(Ad(FB)) #페이스북 종목 수정주가를 시계열로 보기
head(NVDA)
chart_Series(Ad(NVDA)) #엔비디아 종목 수정주가를 시계열로 보기

##국내 종목 주가 다운로드
#getsymbols는 국내 주가도 다운로드 가능하다.
#코스피 상장은 티커.KS, 코스닥 상장 종목의 경우 티커.KQ의 형태로 입력한다.

#코스피 상장 종목인 삼성전자 데이터의 다운로드 예시
getSymbols('005930.KS',
           from = '2000-01-01', to = '2018-12-31')
tail(Ad(`005930.KS`))
#티커명에 .이 있으므로 변수로 티커명을 넣을때 인식시키려면 ``로 감싸주어야함
#작은따옴표가 아니야!

#국내 종목은 종종 수정주가가 오류나는 경우가 많으므로 배당이 반영된 값보다는
#단순 종가인 Close 데이터를 사용하는 것을 권장

tail(Cl(`005930.KS`))
#Cl함수는 Close 즉 종가만을 선택, 사용 방법은 Ad() 함수와 동일하다.
#비록 배당은 고려할 수 없지만 오류가 없는 데이터를 사용할 수 있다.

chart_Series(Cl(`005930.KS`))

#셀트리온
getSymbols('068760.KS') #결측치가 많으니 참고하라고 뜬다.
na.omit(`068760.KS`) #결측치 제거
tail(Cl(`068760.KS`)) #끝부분 보기
chart_Series(Cl(`068760.KS`)) #시계열로 함 봐보기 코로나로 떡상한게 보인다.

#FRED 데이터 다운로드
#미국 연방 준비 은행의 자료도 getsymbol함수로 데이터 다운로드 가능하다

getSymbols('DGS10', src = 'FRED') #FRED로 부터 미 국채 10년물 금리를 다운
chart_Series(DGS10)#시계열로 본다.
#미 국채 10년물 금리에 해당하는 티커가 DGS10인 것이다.

#각 항목별 티커를 찾는 방법
#FRED웹사이트에 접속해서 원하는 데이터 검색한다. 
#웹 페이지 주소에서 /series/다음에 위치하는 것이 해당항목의 티커다.

getSymbols('DEXKOUS', src = 'FRED') #DEXKOUS는 원/달러 환율에 해당하는 티커
chart_Series(DEXKOUS) #IMF위기 시기가 두드러진다.

#20년 10월 18일 오늘은 요까지


