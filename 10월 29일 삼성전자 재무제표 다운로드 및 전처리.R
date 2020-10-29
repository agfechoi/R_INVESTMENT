#10월 29일 재무제표 및 가치지표 크롤링

#재무제표는 투자에 있어서 핵심이 되는 데이터다.
#국내 데이터 제공업체인 FnGuide에서 운영하는 Company Guide 웹사이트에서 구할 수 있다.

#개별종목의 재무제표 탭을 선택하면 포괄손익계산서, 재무상태표, 현금흐름표 항목이
#보인다. 그리고 티커 뒤에 주소는 불필요한 내용이므로 이를 제거한 주소로 접속한다.

#http://comp.fnguide.com/SVO2/ASP/SVD_main.asp?pGB=1&gicode=A005930
#A뒤에 티커만 변경해주면 해당 종목의 재무제표 페이지로 이동하게 된다.

#우리가 원하는 재무제표 항목들은 모두 테이블 형태로 제공되고 있으므로 html_table()
#함수를 이용해서 추출할 수 있다.

library(httr)
library(rvest)
getwd()
setwd("C:/Users/user/Desktop/new/data")
Sys.setlocale("LC_ALL", "English") #Sys.setlocale함수로 로케일 언어를 영어로
#설정한다. 한국어인 상태로 바로 하면 에러가 날 우려가 있다. 그래서
#영어로 설정하고 긁은다음에 다시 한국어로 바꾸는 과정을 거친다.

url = paste0("http://comp.fnguide.com/SVO2/ASP/SVD_Finance.asp?pGB=1&gicode=A005930")
#url을 받는다. 

data = GET(url, user_agent('Mozilla/5.0 (Windows NT 10.0; Win64; x64) # 웹브라우저 구별 입력
							# 웹 브라우저 리스트 http://www.useragentstring.com/pages/useragentstring.php 에서 확인
							AppleWebKit/537.36 (KHTML, like Gecko) Chrome/70.0.3538.77 Safari/537.36'))
#url을 GET()함수를 써서 페이지 내용을 받아오는데 이때 그냥 받아오면
#이 웹싸이트가 브라우저가 아닌 곳을 통한 접속인걸 알아채고 접속을 거부하므로
#브라우저에서 들어가는 것처럼 속인다. user_agent함수가 그 부분이다.

data <- data %>% 
  read_html() %>%   #read_html함수를 통해 html내용을 읽어오며
  html_table()  #html_table함수를 통해 테이블 내용만 추출한다.

Sys.setlocale("LC_ALL", "Korean") #로케일 언어를 다시 한국어로 설정한다.

lapply(data, function(x) {
  head(x,3)})

#이 과정들을 거치면 data변수에는 리스트 형태로 총 6개의 테이블이 들어오게 되고
#그 내용은 다음과 같다.
#1. 포괄손익계산서(연간) 2. 포괄손익계산서(분기) 3. 재무상태표(연간)
#4. 재무상태표(분기) 5. 현금흐름표(연간) 6. 현금흐름표(분기)

#이중 연간 기준 재무제표에 해당하는 1, 3, 5 테이블을 선택한다.

data_IS <- data[[1]]
data_BS <- data[[3]]
data_CF <- data[[5]]

print(names(data_IS))

data_IS <- data_IS[, 1:(ncol(data_IS)-2)] #전년동기, 전년동기(%)열이 마지막
#두 열에 있는데 통일성을 위해서 해당 열을 삭제해주는 코드.
#이 과정을 왜 해주냐하면 data_BS랑 data_CF에는 저 두열이 없어서 통일성을
#맞춰주기 위해서 제거해주는 거다.

data_fs <- rbind(data_IS, data_BS, data_CF)
#rbind함수를 통해서 세 테이블을 행으로 묶은 후 data_fs에 저장한다.

data_fs[, 1] <- gsub('계산에 참여한 계정 펼치기',
                     '', data_fs[, 1])
#첫 번째 열인 계정명에 '계산에 참여한 계정 펼치기'라는 글자가 들어간
#항목이 있다. 이는 페이지 내에서 펼치기 역할을 하는 (+) 항목에 해당하므로
#필요없는거다. 그래서 gsub함수를 이용해서 해당 글자를 삭제해준다.

data_fs <- data_fs[!duplicated(data_fs[, 1]), ]
#중복되는 계정명이 몇몇 있는데 대부분 불필요한 항목들이다.
#!duplicated함수를 사용해서 중복되지 않는 계정명만 선택한다.

rownames(data_fs) = NULL #행 이름들 초기화
rownames(data_fs) = data_fs[, 1] #첫번째 열의 계정명을 행 이름으로 변경
data_fs[, 1] = NULL #필요없어진 첫번째 열은 삭제한다.

data_fs <- data_fs[, substr(colnames(data_fs), 6, 7) == '12']
#간혹 12월 결산법인이 아닌 종목이거나 연간 재무제표임에도 불구하고 
#분기 재무제표가 들어가는 경우가 있다. 비교의 통일성을 위해 substr()함수를
#이용해서 끝 글자가 12인 열, 즉 12월 결산 데이터만 선택한다.
#2020년 6월꺼가 사라진다!

head(data_fs)
#데이터를 확인해보면 연간 기준 재무제표가 정리되었다. 

sapply(data_fs, typeof)
#그런데 숫자가 문자형 데이터로 되어 있으므로 이를 숫자형으로 변경해줘야 한다.
#숫자 사이사이 , 때문에 문자형 데이터로 인식되고 있는거다.

library(stringr)
data_fs <- sapply(data_fs, function(x) { #sapply함수를 이용해서 각 열에
  str_replace_all(x, ',', '') %>% #stringr 패키지의 str_replace_all 함수를
    as.numeric() #적용, 숫자형 데이터로 변경해준다.
}) %>% 
  data.frame(., row.names = rownames(data_fs)) #data.frame함수를 써서
#데이터 프레임 형태로 만들어주고 행 이름은 기존 내용을 그대로 유지해준다.

sapply(data_fs, typeof)
#확인해보면 문자형이던 데이터가 숫자형으로 변경되었다. 

write.csv(data_fs, "005930_fs.csv")
#이렇게 완성된 삼성전자 재무제표를 저장한다.



