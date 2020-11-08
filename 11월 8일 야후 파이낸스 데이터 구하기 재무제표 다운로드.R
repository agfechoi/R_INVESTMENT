getwd()
setwd()

#6.3.1 재무제표 다운로드
#먼저 야후 파이낸스에 접속해 삼성전자 티커에 해당하는 005930.KS를 입력한다
#그 후 재무제표 데이터에 해당하는 [Financials]항목을 선택한다.

#보면 손익계산서(Income Statement), 재무상태표(Balance Sheet), 현금흐름표(Cash Flow)
#총 세 개 지표가 있다. 각각의 URL은 다음과 같다.

#(Income statement) = https://finance.yahoo.com/quote/005930.KS/financials?p=005930.KS
#(Balance Sheet) = https://finance.yahoo.com/quote/005930.KS/balance-sheet?p=005930.KS
#(Cash Flow) = https://finance.yahoo.com/quote/005930.KS/cash-flow?p=005930.KS

#각 페이지에서 Xpath를 이용해 재무제표에 해당하는 테이블 부분만을 선택해
#추출할 수 있다. 세 개 페이지의 해당 xpath는 다음과 같이 동일하다.

# //*[@id="Col1-1-Financials-Proxy"]/section/div[3]/table

#위 정보를 이용해 재무제표를 다운로드 하는 과정은 다음과 같다.
library(httr)
library(rvest)

url_IS <- paste0('https://finance.yahoo.com/quote/005930.KS/financials?p=005930.KS')

url_BS <- paste0('https://finance.yahoo.com/quote/005930.KS/balance-sheet?p=005930.KS')

url_CF <- paste0('https://finance.yahoo.com/quote/005930.KS/cash-flow?p=005930.KS')

yahoo_finance_xpath <- '//*[@id="Col1-1-Financials-Proxy"]/section/div[3]/table'
#앞에서 구한 URL을 저장합니다. 이부분에서 TABLE을 못찾겠다. 
#그래서 밑에 html_table()에서 오류가 나는 듯 하다. 추후 좀더 알아봐야 할듯.


data_IS <- GET(url_IS) %>% 
  read_html() %>%  #get으로 페이지 정보를 받아온 후 read로 html 정보 받아온다.
  html_node(xpath = yahoo_finance_xpath) %>% 
  html_table() #앞에서 구한 xpath로 테이블 부분의 html을 선택한 후 테이블만 추출

data_BS <- GET(url_BS) %>% 
  read_html() %>% 
  html_node(xpath = yahoo_finance_xpath) %>% 
  html_table()

data_CF <- GET(url_CF) %>% 
  read_html() %>% 
  html_node(xpath = yahoo_finance_xpath) %>% 
  html_table()

data_fs <- rbind(data_IS, data_BS, data_CF) 
#세 페이지에 동일하게 적용 후 rbind로 행으로 묶어준다.

print(head(data_fs))

#저 yahoo_finance_xpath를 구하는 부분이 안되는걸 봐선 xpath가 변경된 모양인데
#슥슥 찾아서는 table 형태가 안나온다.. 왜이럴까..