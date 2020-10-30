#10월 30일 가치지표 계산하기

#29일 구한 재무제표 데이터를 이용해서 가치지표를 계산할 수 있다.
#흔히 사용되는 가치지표는 PER, PBR, PCR, PSR이며 분자는 주가, 분모는 재무제표
#데이터가 사용됩니다.

#순서       분모
#PER      순이익
#PBR      순자산
#PCR  영업활동현금흐름
#PSR      매출액

#위에서 구한 재무제표 항목에서 분모 부분에 해당하는 데이터만 선택해본다.

value_type <- c("지배주주순이익",
                '자본',
                '영업활동으로인한현금흐름',
                '매출액') #분모에 해당하는 항목을 저장한다.

value_index <- data_fs[match(value_type, rownames(data_fs)),
                       ncol(data_fs)] #match함수를 써서 해당 항목이 위치하는
#지점을 data_fs에서 찾는다. ncol()함수를 이용해서 맨 오른쪽, 최근년도 재무제표
#데이터를 선택한다. 즉 2019년 12월 데이터다.

#다음으로 분자 부분에 해당하는 현재 주가를 수집해야 한다. 이 역시 
#Company Guide 접속 화면에서 구할 수 있다.

#http://comp.fnguide.com/SVO2/ASP/SVD_Main.asp?pGB=1&gicode=A005930
#위 주소 역시 A뒤의 6자리 티커만 변경하면 해당 종목의 스냅샷 페이지로
#이동하게 된다.

#주가추이 부분에 우리가 원하는 현재 주가가 있다. 해당 데이터의 Xpath는
#다음과 같다.
# //*[@id="svdMainChartTxt11"]

#위에서 구한 주가의 Xpath를 이용해 해당 데이터를 크롤링한다.

library(readr)

url = paste0('http://comp.fnguide.com/SVO2/ASP/SVD_Main.asp?pGB=1&gicode=A005930')

data = GET(url, user_agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) # 웹브라우저 구별 입력
							# 웹 브라우저 리스트 http://www.useragentstring.com/pages/useragentstring.php 에서 확인
							AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36'))
#url을 입력한 후 GET으로 받아오는데 저번처럼 그냥 URL만 쓰면 뱉어내므로
#브라우저를 통해 들어간거처럼 속인다.

price <- read_html(data) %>% 
  html_node(xpath = '//*[@id="svdMainChartTxt11"]') %>% #read_html로 html을
  #불러오고 html_node()함수에 앞서 구한 xpath를 입력해 해당 지점 데이터 추출
  html_text() %>% 
  parse_number() #html_text로 text만 받아오고 parse_num함수 적용한다.
#parse_num함수는 문자형 데이터에서 콤마와 같은 불필요한 문자를 제거한 후 
#숫자형 데이터로 변경해준다.
price

#가치지표를 계산하려면 발행주식수 역시 필요하다. 예를 들어 PER을 계산하는
#방법은 다음과 같다.

#PER = Price/EPS = 주가/주당순이익

#주당순이익은 순이익을 전체 주식수로 나눈 값이므로, 해당 값을 계산하려면 
#전체 주식수를 구해야한다. 전체 주식수 데이터 역시 웹페이지에 있으므로
#앞서 주가를 크롤링한 방법과 동일한 방법으로 구할 수 있다.
#전체 주식수 데이터의 xpath는 다음과 같다.

# //*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]

#이를 이용해 발행주식수 중 보통주를 선택하는 방법은 다음과 같다.

share = read_html(data) %>% 
  html_node(
    xpath = '//*[@id="svdMainGrid1"]/table/tbody/tr[7]/td[1]') %>% 
  html_text()

share
#read함수와 node함수를 써서 html에서 xpath에 해당하는 데이터 추출한다.
#그 후 html_text함수를 통해 텍스트부분만 추출한다.
#해당 과정을 거치면 보통주/우선주 형태로 발행주식주가 저장된다.
#이중 우리가 원하는 데이터는 /앞에 있는 보통주 발행주식수이다.

share <- share %>% 
  strsplit('/') %>% #strsplit을 통해 /를 기준으로 데이터를 나눈다. 
  unlist() %>% #unlist로 리스트를 벡터 형태로 변환한다.
  .[1] %>%  #.[1]을 통해 보통주 발행주식수인 첫 번째 데이터를 선택한다.
  parse_number() #문자형 데이터를 숫자형으로 변환한다.

share #보통주 주식수만 땋 나옴

#재무데이터, 현재 주가, 발행주식수를 이용해서 가치지표를 계산해보자

data_value <- price / (value_index * 100000000 / share)
names(data_value) = c('PER', 'PBR', 'PCR', 'PSR')
data_value[data_value < 0] = NA
data_value

#분자에는 현재 주가를 입력하고 분모에는 재무 데이터를 보통주 발행주식수로
#나눈 값을 입력한다. 단, 주가는 원단위, 재무 데이터는 억원 단위이므로
#둘 사이에 단위를 동일하게 맞춰주기 위해 분모에 억을 곱한다.
#또한 가치지표가 음수인 경우에는 NA로 변경해준다.

data_value #결과를 보면 네 가지 가치지표가 잘 계산되었다.
getwd()
write.csv(data_value, "005930_value.csv")
