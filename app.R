library(shiny)
library(shinydashboard)
library(rsconnect)
library(ggplot2)
library(Rcpp)

library(FactoMineR)
library("factoextra")
source('fonctions.R')


header<-dashboardHeader(title="Rapport d'activité")

sidebar <- dashboardSidebar(
  sidebarMenu(
    # Setting id makes input$tabs give the tabName of currently-selected tab
    id = "tabs",
    menuItem("Présentation", tabName = "presentation", icon = icon("house")),
    menuItem("Questionnaire", icon = icon("pencil"),
             menuSubItem("Votre test de personnalité",tabName = "test1"),
             menuSubItem("Données de ce test",tabName = "test2")
    ),
    menuItem("Code disponible", tabName="code",icon = icon("code")
    )
  ))




body<-dashboardBody(tabItems(
  tabItem("presentation",h2("Présentation"),
          box(width = 100,
          "Cette application Shiny a été créée dans le cadre d'un cours sur R. Le but étant de se familiariser avec différentes fonctionnalités de R.",tags$br(),
          "Dans mon cas j'ai centré mon projet autour de l'idée de mettre en place un test de personnalité sur une application R Shiny que voici.",tags$br(),
          "Vous trouverez dans l'onglet questionnaire le test que vous pouvez faire, qui vous retournera un score selon plusieurs paramètres, il y a aussi
          une simple analyse de données selon les résultats déjà collectés sur Kaggle.
          Dans l'ongle code vous trouverez des informations complémentaires sur le code , pour mieux comprendre ma démarche et mon cheminement vous pouvez aussi télécharger mon rapport d'activité:",tags$br(),
          downloadLink('downloadData', 'Download'))
  ),
  tabItem("test2",tags$title("Votre Test"),  # Start Test Tab and html title tag
            h2("Données de ce test"),
          box(width = 100,
              
              
              "On peut effectuer une rapide analyse de données à partir des données récoltées par ce test.Notons que les réponses des participants sont basées sur un ressenti personnel et sont donc très subjectives.
                Les rapprochements que l'on pourra faire dans la suite de cette page sont donc à prendre avec des pincettes.
                De plus il faut notez que les donnnées que nous utilisons sont celles ici des réponses sur ce site, mais surtout les réponses
                d'une base de données trouvée sur kaggle.",
              tags$hr()),
          h2("Base de données"),
          box(width = 100,
              "Les données initiales (non-completées par ce site), sont disponibles ici:",
              tags$a(href = "https://www.kaggle.com/datasets/lucasgreenwell/ocean-five-factor-personality-test-responses/code?select=data.csv","data Kaggle"),
              "On voit qu'elles contiennent 7 questions supplémentaires à notre test, celle-ci ne sont pas reliées au score que l'on obtient c'est pour
              ça que je les ai considérées comme facultatives. Cependant il est intéressant de voir comment certains caractères sociaux peuvent influer sur les résultats de ce test.
              Parmi ces 7 caractères supplémentaires, je n'ai gardé que ceux concernant:",tags$br(),
              "-le genre: 'Homme','Femme','Autre'",tags$br(),
              "-la main dominante: 'Droitier','Gaucher','Ambidextre'",tags$br(),
              "-l'age: en années.",tags$br(),
              "Ici je me suis contentée d'afficher les résultats principaux d'une simple ACP sur les résultats obtenus à ce test selon ces variables supplémentaires",
              tags$br(),
              "Pour l'age j'ai choisi d'afficher une autre ACP qui inclut aussi l'age dans les variables (alors que l'age est une simple variable supplémentaire sur les autres graphique)",tags$br(),
              tags$br(),
              "Notez que dans tous les cas ces ACPs on une variance cumulée d'environ 50%, c'est-à-dire que ces graphiques n'expliquent que 50% des résultats",tags$br(),
              "C'est pour ça je me passe de commentaires sur ces donnéees car tout ce qui suit est à prendre avec des pincettes",tags$br()
              , "Cliquez sur l'onglet qui vous intéresse",tags$br()),
          h2("Visualisation des données"),
          box(width=100,
              tabBox(
## Start Tabbox for results
                width = 100,
                tabPanel("Résultats sur les genres",     # Table Panel 1 Open

                         tags$hr(),
                         
                         h2("Visualisation des différentes catégories de genre par rapport aux autres variables"),
                         plotOutput("acpgenre")

                         ## Here is where the rShiny score feeds things back to them



                ),
                tabPanel("Résultats globaux & age",     # Table Panel 1 Open
                         
                         
                         h2("Visualisation de l'age par rapport aux autres variables en incluant l'age dans l'ACP"),

                         plotOutput("acpage")
                         
                         ## Here is where the rShiny score feeds things back to them
                         
                         
                         
                ),
                tabPanel("Résultats sur la main dominante",     # Table Panel 1 Open
                         
                         h2("Visualisation des différentes catégories de main dominante par rapport aux autres variables") ,
                         plotOutput("acpmain")
                         
                         ## Here is where the rShiny score feeds things back to them
                         
                         
                         
                ),
                tabPanel("Résultats plus détaillés sur le genre", 
                         tags$hr(),
                         h2("Histogramme des résultats pour la catégorie: homme"),
                         plotOutput("homme"),tags$br(),
                         
                         h2("Histogramme des résultats pour la catégorie: femme"),plotOutput("femme"),tags$br(),
                         
                         h2("Histogramme des résultats pour la catégorie: autre"),plotOutput("autre")
                         
                         ## Here is where the rShiny score feeds things back to them
                         
                         
                         
                )

              )  ## Close Tab Box
          )),
           
  tabItem("test1",tags$title("Votre Test"),  # Start Test Tab and html title tag
                  h2("Testez-vous"),
                  # Sidebar with the scale items
                  box(width = 100,
                                                        
                                                        
                                                         "Veuillez indiquer à quel point vous êtes d'accord avec les affirmations suivantes.
                              Sachez qu'il n'y a pas de bonnes ou de mauvaises réponses. N'hesitez pas à vous refferez à e que vous avez ressenti au cours de cette dernière année. 
                              Ne vous fiez pas à votre état d'esprit d'aujourd'hui.
                              Vos réponses seront enregistrées de manière anonyme, en poursuivant ce test vous consentez à ce qu'elles soient utilisées et publiées.",
                                                        tags$hr(),
                      g(dataquest)
                                                        ,
                      
                      actionButton(inputId = "n", label = "Soumettre vos réponses et obtenir votre score", icon = icon("user-circle")),
                      conditionalPanel("input.n == 1",         ## Start the conditional Panel for the Results, N == 1
                                       
                                       
                                       tabBox(                                         ## Start Tabbox for results
                                         title = "Vos résultats", width = 100,
                                         tabPanel("Compared to our normative sample",     # Table Panel 1 Open
                                                  
                                                  h2("Votre score") ,
                                                  
                                                  plotOutput("Curve",
                                                             # width="600px",
                                                             # height = "80px"
                                                             ), 
                                                  tags$hr(),
                                                  textOutput("Output"), 
                                                  tags$hr(),
                                                  h2("Les résultats globaux à ce test"),
                                                  plotOutput("hist"),
                                                  textOutput("nombre")
                                                  
                                                    ## Here is where the rShiny score feeds things back to them
                                                  
                                         
                      
                  ) 
    
                   )  ## Close Tab Box
  ))),  # Close Results tab item
                                                
  tabItem("code",tags$title("Où retrouvez le code"),  # Start Test Tab and html title tag
          h2("Où retrouvez le code"),
          box(width = 100,
              
              
              "Vous pouvez retrouvez le code qui génère cette application sur mon git:",tags$br(),
              tags$a(href="https://github.com/alicechevaux/projetRM1","mon git"),tags$br(),
              "En particulier le code concernant le test a été créé pour être reproducible avec n'importe quel autre test",tags$br(),
              "Vous retrouverez notamment les informations néessaires pour le réutiliser avec un certain format de dataframe",
              tags$hr()),
)
))

ui <- dashboardPage(header,sidebar,body)

#Résultats<-gs4_get("https://docs.google.com/spreadsheets/d/1D2ASQQ6r313gQ1X-tdqkmSYpHpOZX9yg63xfxseVK20/edit?usp=sharing")
server <- function(input, output) {
  
  
  Results <- reactive({ #c(as.numeric(input$E1),as.numeric(input$E2),as.numeric(input$E3),as.numeric(input$E4)))
    x=NULL
    for (i in c(1:nrow(dataquest))){
      x<-c(x,as.numeric(do.call("$",list(input,df1[i,1]))))    #il faut trouver comment pouvoir appeler les input alorsque c'est des attributs
    }
    x
  })
  
  

  Score<-reactive({
    z=replicate(length(res),0)
    for (j in c(1:length(res))){
      for (i in c(1:length(as.vector(Results())))){
        z[j]=z[j]+(as.vector(Results())[i]-3)*(as.vector(df1[[i,j+2]]))/2
      }
    }
    z/scoremax
  }
  )
  
  observeEvent(input$n, {                                      #  Observe event action from Actionbutton
    data<-rbind(data,as.vector(Results()))
    save(data,file='www/data.rda')
    
    
    
  })
  output$Output <- renderText({
    w=NULL
    for (i in c(1:(length(res)))) {
      w<-c(w,"Votre score de",res[i],"est de",(Score()[i]+1)*50)  
    }
    paste(w)
  })
  output$Curve <- renderPlot({
    vecteur=NULL
    for (i in c(1:length(res))){
      vecteur<-c(vecteur,(Score()[i]+1)*50)
    }
    vecteur<-c(vecteur,100-vecteur)
    df2 <- data.frame(
      Résultats = rep(res,2),
      pourcentage=vecteur,
      ratio=rep(c("oui", "non"), each = length(res))
    )
    ggplot(df2, aes(x = Résultats, y = pourcentage))+
      geom_col(aes(fill = ratio), width = 0.7)+
      scale_fill_manual(values=c('white','grey50'))+
      coord_flip()

    })
  output$hist<-renderPlot({
    ggplot(long, aes(x=score,fill=type)) +
      geom_histogram(binwidth = 1)+
      facet_wrap(~type,ncol=1)
  })
  output$nombre<-renderText({
    paste(c("vous êtes",nrow(data),"à avoir répondu à ce test"))
  })
  output$acpgenre<-renderPlot({
    acp2<-PCA(complet2,quanti.sup=1,quali.sup=2:3,graph=F)
    p<-fviz_pca_var(acp2)
    fviz_add(p,acp2$quali.sup$coord[1:3,], color = "red")
  })
  output$acpmain<-renderPlot({
    acp2<-PCA(complet2,quanti.sup=1,quali.sup=2:3,graph=F)
    p<-fviz_pca_var(acp2)
    fviz_add(p,acp2$quali.sup$coord[4:6,], color = "red")
  })
  output$acpage<-renderPlot({
    acp<-PCA(complet2,quali.sup=2:3,graph=F)
    fviz_pca_var(acp)
  })
  output$femme<-renderPlot({
    ggplot(long2[which(long2$gender=='Femme'),], aes(x=score,fill=type)) + 
      geom_histogram(binwidth = 1)+
      facet_wrap(~type,ncol=1)
  })
  output$homme<-renderPlot({
    ggplot(long2[which(long2$gender=='Homme'),], aes(x=score,fill=type)) + 
      geom_histogram(binwidth = 1)+
      facet_wrap(~type,ncol=1)
  })
  output$autre<-renderPlot({
    ggplot(long2[which(long2$gender=='Autre'),], aes(x=score,fill=type)) + 
      geom_histogram(binwidth = 1)+
      facet_wrap(~type,ncol=1)
  })
  output$coucou<-renderPlot({
    plot(c(1:10),c(1:10))
  })
  
  output$downloadData <- downloadHandler(filename="rapport.html",content="rapport.html")
  
  
  
}

shinyApp(ui,server) 

# faudra recuperer les données en tapant /data.rda a la fin du l'url de l app
# attention toujours mettre un () après une variable qui depend d'une fct reactive()


