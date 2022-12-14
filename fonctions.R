
g=function(df){
  y=NULL
  for (i in c(1:nrow(df))){
    y<-list(y,selectInput(inputId = df[i,1] ,     #il faut utiliser list au lieu de append sinon des bouts de java script apparaissent
                            label = df[i,2],
                            choices = c("Pas d'accord" = 1, "Pas trop d'accord" = 2, "Ni l'un ni l'autre" = 3, 
                                        "Plutôt d'accord" = 4, "D'accord" = 5),
                            selectize=F,
                            size=5,
                            selected = 3))
              }
  y
}




#setwd('C:/R/app/newapp')
#la df des resultats 
df1<-read.csv('questions.csv',head=T) #la df des questions et des coef correspondants

load('www/data.rda')

dataquest<-df1[sample(1:nrow(df1),nrow(df1)),] #on modifie l'ordre aleatoirement pour que le test soit melangé
res1=names(dataquest)
res=res1[-c(1,2)]

#ici on doit avoir modifié les df pour que ca soit reproducible ie bien nommé dans df1 et avoir déjà viré les colonnes de data1



scoremax<-{
  m=replicate(length(res),0)
  for (j in c(1:length(res))){
    for (i in c(1:nrow(dataquest))){
      m[j]<-m[j]+abs(dataquest[[i,j+2]])
    }
  }
  m
}


cppFunction(' 
 Rcpp::NumericVector cpp_h(Rcpp::NumericVector l,DataFrame df) {
   const int n = l.size();
   Rcpp::NumericVector result (5);
   const int m = result.size();
   for (int j=0;j<m;j++) {
     NumericVector v=df[j+2];
     for(int i=0; i<n; i++){
        result[j] = result[j]+(l[i]-3)*v[i]/2;
     };
   }
   return result;
 }
')

cpp_h2=function(x){cpp_h(x,df1)}
scoretest<-apply(data,1,cpp_h2)
scoretest<-as.data.frame((t(scoretest)/scoremax+1)*50)
names(scoretest)<-res

long <- reshape(data = scoretest, 
                v.names=c("score"),
                varying = c(names(scoretest)),
                timevar = "type",
                times=c(names(scoretest)),
                direction = "long")

