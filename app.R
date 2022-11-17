library(shiny)
library(shinydashboard)
library(rsconnect)
library(ggplot2)
library(Rcpp)
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
    menuItem("Code disponible", icon = icon("display-code")
    )
  ))




body<-dashboardBody(tabItems(
  tabItem("presentation",
          "blablabla"
  ),
  tabItem("test2",tags$title("Votre Test"),  # Start Test Tab and html title tag
            h2("Données de ce test"),
            # Sidebar with the scale items
            box(width = 100,
                
                
                        "On peut effectuer une rapide analyse de données à partir des données récoltées par ce test.Notons que les réponses des participants sont basées sur un ressenti personnel et sont donc très subjectives.
                Les rapprochements que l'on pourra faire dans la suite de cette page sont donc à prendre avec des pincettes.
                De plus il faut notez que les donnnées que nous utilisons sont celles ici des réponses sur ce site, mais surtout les réponses 
                d'une base de données trouvée sur kaggle.",
                tags$hr()),
          h2("Base de donnée"),
          box(width = 100,
              "Les données initiales (non-completées par ce site), sont disponibles ici:",
              href = "https://www.kaggle.com/datasets/lucasgreenwell/ocean-five-factor-personality-test-responses/code?select=data.csv",
              "On voit qu'elles contiennent 7 questions supplémentaires à notre test, celle-ci ne sont pas reliées au score que l'on obtient c'est pour
              ça que je les ai considérées comme facultatives. Cependant il est intéressant de voir comment certains caractères sociaux peuvent influer sur les résultats de ce test.
              Parmi ces 7 caractères supplémentaires, je n'ai gardé que ceux concernant:",tags$br(),
              "-le genre: 'Homme','Femme','Autre'",tags$br(),
              "-la main dominante: 'Droitier','Gaucher','Ambidextre'",tags$br(),
              "-l'age: en années."
              
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
                                                        
  tabItem("test2",
          "Sub-item 2 tab content"
  ),
  tabItem("donnees1","rien"),
  tabItem("donnees2","rien2")
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
      geom_histogram(binwidth = 0.5)+
      facet_wrap(~type,ncol=1)
  })
  output$nombre<-renderText({
    paste(c("vous êtes",nrow(data),"à avoir répondu à ce test"))
  })
  
}

shinyApp(ui,server) 

# faudra recuperer les données en tapant /data.rda a la fin du l'url de l app
# attention toujours mettre un () après une variable qui depend d'une fct reactive()


