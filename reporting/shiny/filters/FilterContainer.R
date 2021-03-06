library("R.oo", quietly = TRUE)


setConstructorS3(name = "FilterContainer", function(){
  extend(Object(), "FilterContainer",
         .selections = NULL,
         .result = NULL,
         .scenario = NULL,
         .tool = NULL,
         .case = NULL,
         .size = NULL,
         .phase = NULL,
         .metric = NULL,
         .iteration = NULL,
         .xDimension = NULL,
         .legend = NULL,
         .specificLegend = NULL,
         .publishing = NULL
         )
})


setMethodS3(name = "init", class = "FilterContainer", function(this){
  sel <- Selections()
  this$.selections <- sel
  
  this$.scenario <- ScenarioFilter(sel)
  this$.scenario$setContainer(this)
  this$.scenario$.allStates <- unique(this$.result$.frame$Scenario)
  this$.scenario$update()
  
  this$.tool <- ToolFilter(sel)
  this$.tool$setContainer(this)
  this$.tool$.allStates <- unique(this$.result$.frame$Tool)
  this$.tool$update()
  
  this$.case <- CaseFilter(sel)
  this$.case$setContainer(this)
  this$.case$.allStates <- unique(this$.result$.frame$CaseName)
  this$.case$update()
  
  this$.size <- SizeFilter(sel)
  this$.size$setContainer(this)
  this$.size$.allStates <- unique(this$.result$.frame$Size)
  this$.size$update()
  
  this$.phase <- PhaseFilter(sel)
  this$.phase$setContainer(this)
  this$.phase$.allStates <- unique(this$.result$.frame$PhaseName)
  this$.phase$update()
  
  this$.metric <- MetricFilter(sel)
  this$.metric$setContainer(this)
  this$.metric$.allStates <- unique(this$.result$.frame$MetricName)
  this$.metric$update()
  
  this$.iteration <- IterationFilter(sel)
  this$.iteration$setContainer(this)
  this$.iteration$update()
  
  this$.xDimension <- XDimensionFilter(sel)
  this$.xDimension$setContainer(this)
  this$.xDimension$.allStates <- c("Scenario", "CaseName", "Tool", "Size", "Iteration")
  this$.xDimension$.selectedState <- "Size"
  this$.xDimension$update()
  
  this$.legend <- LegendFilter(sel)
  this$.legend$setContainer(this)
  this$.legend$.allStates <- c("Scenario", "CaseName", "Tool", "MetricName")
  this$.legend$.selectedState <- "MetricName"
  this$.legend$update()
  
  this$.specificLegend <- SpecificLegendFilter(sel)
  this$.specificLegend$setContainer(this)
  this$.specificLegend$.allStates <- NULL
  this$.specificLegend$update()

  this$.publishing <- PublishingFilter(sel)
  this$.publishing$setContainer(this)
  this$.publishing$.allStates <- sel$.defaultSelections
  this$.publishing$update()
  
})


setMethodS3(name = "setResult", class = "FilterContainer", function(this, result){
  if (is.null(result)){
    throw("Null result parameter in FilterContainer - setResult")
  }
  this$.result <- result
})



setMethodS3(name = "getFrameID", class = "FilterContainer", function(this, limit = "Size"){
  id <- "ID"
  for(select in this$.selections$.defaultSelections){
    if(select == limit){
      return(id)
    }
    if (select %in% this$.selections$.selections){
      id <- paste(id, this$getFilter(select)$.selectedState, sep=".")
    }
  }
  return(id)
})


setMethodS3(name = "getFilter", class = "FilterContainer", function(this, selected){
  if(selected == "Scenario"){
    return(this$.scenario)
  }
  if(selected == "CaseName"){
    return(this$.case)
  }
  if(selected == "Tool"){
    return(this$.tool)
  }
  if(selected == "Size"){
    return(this$.size)
  }
})


setMethodS3(name = "injectStates", class = "FilterContainer", function(this, text){
  text <- gsub(pattern = "SCENARIO", replacement = this$.scenario$.selectedState, text)
  text <- gsub(pattern = "CASENAME", replacement = this$.case$.selectedState, text)
  text <- gsub(pattern = "TOOL", replacement = this$.tool$.selectedState, text)
  text <- gsub(pattern = "SIZE", replacement = this$.size$.selectedState, text)
  return(text)
})


setMethodS3(name = "notifyViews", class = "FilterContainer", function(this, observers){
  this$.xDimension$notifyView(observers)
  this$.xDimension$notifyNextView(observers)
  
  this$.legend$notifyView(observers)
  this$.legend$notifyNextView(observers)
  
  this$.publishing$notifyView(observers)
  this$.publishing$notifyNextView(observers)
  
  this$.scenario$notifyView(observers)
  this$.scenario$notifyNextView(observers)
})


setMethodS3(name = "updateFilters", class = "FilterContainer", function(this){
  this$.publishing$update()
  this$.publishing$updateNext()
  this$.scenario$update()
  this$.scenario$updateNext()
})


setMethodS3(name = "import", class = "FilterContainer", function(this, config){
  this$.xDimension$.selectedState <- updateConfigData(this$.xDimension$.selectedState, config, "X_Dimension")
  this$.legend$.selectedState <- updateConfigData(this$.legend$.selectedState, config, "Legend")
  
  this$.specificLegend$.selectedState <- updateConfigData(this$.specificLegend$.selectedState, config, "Legend_Filters")
  
  specLegend <- this$.specificLegend$.selectedState
  if (is.null(config$Legend_Filters)){
    this$.specificLegend$.selectedState <- unique(this$.result$.frame[[this$.legend$.selectedState]])
  }
  else if (is.na(config$Legend_Filters)){
    this$.specificLegend$.selectedState <- unique(this$.result$.frame[[this$.legend$.selectedState]])
  }
  this$.phase$.selectedState <- updateConfigData(this$.phase$.selectedState, config, "Summarize_Function")
  
  this$.metric$.selectedState <- updateConfigData(this$.metric$.selectedState, config, "Metrics")
  this$.iteration[1] <- updateConfigData(this$.iteration[1], config, "Min_Iteration")
  this$.iteration[2] <- updateConfigData(this$.iteration[2], config, "Max_Iteration")
})


setMethodS3(name = "export", class = "FilterContainer", function(this){
  if (length(this$.specificLegend$.selectedState) > 1){
    legendFilter <- this$.specificLegend$.selectedState
  }
  else{
    legendFilter <- list(this$.specificLegend$.selectedState)
  }
  
  if (length(this$.phase$.selectedState) > 1){
    phases <- this$.phase$.selectedState
  }
  else{
    phases <- list(this$.phase$.selectedState)
  }
  
  if (length(this$.metric$.selectedState) > 1){
    metrics <- this$.metric$.selectedState
  }
  else{
    metrics <- list(this$.metric$.selectedState)
  }
  
  data <- list(
    "X_Dimension" = this$.xDimension$.selectedState,
    "Legend" = this$.legend$.selectedState,
    "Legend_Filters" = legendFilter,
    "Summarize_Function" = phases,
    "Metrics" = metrics,
    "Min_Iteration" = this$.iteration$.selectedState[1], 
    "Max_Iteration" = this$.iteration$.selectedState[2]
    )
  return(data)
})