#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.CH"

// -------------------------------------------------------
/*/ Rotina FFOMSC01

   Tela de consulta de log do processamento de 
   integração do FUSION x PROTHEUS.

  @author Anderson Almeida - TOTVS
  @since   17/10/2024 
/*/
//--------------------------------------------------------
User Function FFOMSC01()
  Local aCampos := {}

  Private cMensag  := ""
  Private aMensag  := {}
  Private aButtons := {{.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,"Confirmar"},;
                       {.T.,"Fechar"},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil},;
                       {.F.,Nil}}
  Private oTMmGet

  aAdd(aCampos, {"T1_INICIO","D",08,0})
  aAdd(aCampos, {"T1_FIM"   ,"D",08,0})   
  aAdd(aCampos, {"T1_CARGA" ,"C",06,0})

  oTempTable := FWTemporaryTable():New("TRB1")

  oTemptable:SetFields(aCampos)
  oTempTable:AddIndex("01", {"T1_INICIO","T1_FIM","T1_CARGA"})
  oTempTable:Create()

  FWExecView("Consulta Geração Carga","FFOMSC01",MODEL_OPERATION_UPDATE,,{|| .T.},,,aButtons)

  oTempTable:Delete()
Return

// ----------------------------------------------
/*/ ModelDef

    Define as regras de negocio

  @author Anderson Almeida (TOTVS Ne)
  @since  28/08/2024 - Desenvolvimento da Rotina.
/*/
// ----------------------------------------------
Static Function ModelDef() 
  Local oModel
  Local oStruTB1 := fnM01TB1()
  Local oStruTB2 := fnM01TB2()
  Local oStruZ01 := FWFormStruct(1,"Z01")
  
  oModel := MPFormModel():New("FUSION - Geração Carga")  

  oModel:SetDescription("Log")    
  oModel:AddFields("MSTTB1",,oStruTB1)
  
  oModel:AddGrid("DETTB2","MSTTB1",oStruTB2)
  oModel:AddFields("MSTZ01","MSTTB1",oStruZ01)

  oModel:GetModel("MSTTB1"):SetDescription("Log FUSION")  
  oModel:GetModel("DETTB2"):SetDescription("Detalhamento")  
  oModel:GetModel("MSTZ01"):SetDescription("Registro")  

  oModel:SetPrimaryKey({""})

  oModel:GetModel("DETTB2"):SetUniqueLine({"Z01_DATA","Z01_HORA","Z01_CARGA"}) 
Return oModel 

//----------------------------------------------
/*/ fnM01TB1

   Estrutura da pesquisa dos Logs.								  

  @author Anderson Almeida (TOTVS NE)
  Return
  @since 17/10/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------
Static Function fnM01TB1()
  Local oStruct := FWFormModelStruct():New()
  
  oStruct:AddTable("TRB1",{"T1_INICIO","T1_FIM"},"LOG")

  oStruct:AddField("Inicio","Inicio","T1_INICIO","D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Fim"   ,"Fim"   ,"T1_FIM"   ,"D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Carga" ,"Carga" ,"T1_CARGA" ,"C",TamSX3("DAK_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-----------------------------------------
/*/ fnM01TB2
  Estrutura do detalhe dos Logs.							  

  @author Anderson Almeida (TOTVS NE)
  Return
  @história
  25/05/2021 - Desenvolvimento da Rotina.
/*/
//-----------------------------------------
Static Function fnM01TB2()
  Local oStruct := FWFormModelStruct():New()
  
  oStruct:AddTable("SZN",{"ZN_DATA","ZN_HORA","ZN_CARGA"},"Detalhe")
  oStruct:AddField(""             ,""             ,"ZN_STATUS" ,"C",15,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Processamento","Processamento","ZN_DATA"   ,"D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Hora"         ,"Hora"         ,"ZN_HORA"   ,"C",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Carga"        ,"Carga"        ,"ZN_CARGA"  ,"C",TamSX3("DAK_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Data Carga"   ,"Data Carga"   ,"ZN_DTCARGA","D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Recno"        ,"Recno"        ,"ZN_RECNO"  ,"N",10,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------------------------------
/*/ ViewDef()
  Definição da View

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
  Local oModel  := ModelDef() 
  Local oStrTB1 := fnV01TB1() 
  Local oStrTB2 := fnV01TB2()
  Local oStrZ01 := FWFormStruct(2,"Z01")
  Local oView

  oStrZ01:RemoveField("Z01_STATUS")
  
  oView := FWFormView():New() 
   
  oView:SetModel(oModel)    
  oView:SetProgressBar(.T.)
  
  oView:AddUserButton("Legenda","btLeg",{|| fnL01LEG()},"Legenda",,)

  oView:AddOtherObject("FMSG",{|oPanel| fnF01MSG(oPanel)})           // Mensagem do erro
  oView:AddOtherObject("FBOT",{|oPanel| fnF01BTN(oPanel,oView)})     // Botões de Funcionalidade

  oView:AddField("FCAB",oStrTB1,"MSTTB1") 
 
  oView:AddGrid("FDET",oStrTB2,"DETTB2") 
  oView:AddField("FREG",oStrSZN,"MSTZ01") 
  oView:EnableTitleView("FREG","Detalhe")

 // --- Definição da Tela
 // ---------------------
  oView:CreateHorizontalBox("BXCAB",15)

  oView:CreateHorizontalBox("BXDET",75)
  oView:CreateVerticalBox("BVDET",35,"BXDET") 
  oView:CreateVerticalBox("BVMSG",05,"BXDET") 
  oView:CreateVerticalBox("BVREG",60,"BXDET") 

  oView:CreateHorizontalBox("BXBOT",10) 

 // --- Definição dos campos
 // ------------------------    
  oView:SetOwnerView("FCAB","BXCAB")
  oView:SetOwnerView("FDET","BVDET")
  oView:SetOwnerView("FMSG","BVMSG")
  oView:SetOwnerView("FREG","BVREG")
  oView:SetOwnerView("FBOT","BXBOT")

  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})              // Tirar a mensagem do final "Há Alterações não..."

  oView:SetAfterViewActivate({|oView| fnF01REG(oView)})        // Carregar dados antes de montar a tela
Return oView

//-------------------------------------------------------------------
/*/ Função fnV01TB1()
  Estrutura do cabeçalho (View)
  						  
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-------------------------------------------------------------------
Static Function fnV01TB1()
  Local oViewTB1 := FWFormViewStruct():New() 

  oViewTB1:AddField("T1_INICIO",;                // 01 = Nome do Campo
                    "01",;                       // 02 = Ordem
                    "Inicio",;                   // 03 = Título do campo
                    "Inicio",;                   // 04 = Descrição do campo
                    Nil,;                        // 05 = Array com Help
                    "D",;                        // 06 = Tipo do campo
                    "@!",;                       // 07 = Picture
                    Nil,;                        // 08 = Bloco de PictTre Var
                    "",;                         // 09 = Consulta F3
                    .T.,;                        // 10 = Indica se o campo é alterável
                    Nil,;                        // 11 = Pasta do Campo
                    Nil,;                        // 12 = Agrupamnento do campo
                    Nil,;                        // 13 = Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 = Tamanho máximo da opção do combo
                    Nil,;                        // 15 = Inicializador de Browse
                    .F.,;                        // 16 = Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 = Picture Variavel
                    Nil)                         // 18 = Indica pulo de linha após o campo (.T. ou .F.)

  oViewTB1:AddField("T1_FIM",;                   // 01 = Nome do Campo
                    "02",;                       // 02 = Ordem
                    "Fim",;                      // 03 = Título do campo
                    "Fim",;                      // 04 = Descrição do campo
                    Nil,;                        // 05 = Array com Help
                    "D",;                        // 06 = Tipo do campo
                    "@!",;                       // 07 = Picture
                    Nil,;                        // 08 = Bloco de PictTre Var
                    "",;                         // 09 = Consulta F3
                    .T.,;                        // 10 = Indica se o campo é alteravel
                    Nil,;                        // 11 = Pasta do Campo
                    Nil,;                        // 12 = Agrupamnento do campo
                    Nil,;                        // 13 = Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 = Tamanho máximo da opção do combo
                    Nil,;                        // 15 = Inicializador de Browse
                    .F.,;                        // 16 = Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 = Picture Variavel
                    Nil)                         // 18 = Indica pulo de linha após o campo (.T. ou .F.)
  
  oViewTB1:AddField("T1_CARGA",;                 // 01 = Nome do Campo
                    "03",;                       // 02 = Ordem
                    "Carga",;                    // 03 = Título do campo
                    "Carga",;                    // 04 = Descrição do campo
                    Nil,;                        // 05 = Array com Help
                    "C",;                        // 06 = Tipo do campo
                    "@!",;                       // 07 = Picture
                    Nil,;                        // 08 = Bloco de PictTre Var
                    "",;                         // 09 = Consulta F3
                    .T.,;                        // 10 = Indica se o campo é alterável
                    Nil,;                        // 11 = Pasta do Campo
                    Nil,;                        // 12 = Agrupamnento do campo
                    Nil,;                        // 13 = Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 = Tamanho máximo da opção do combo
                    Nil,;                        // 15 = Inicializador de Browse
                    .F.,;                        // 16 = Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 = Picture Variavel
                    Nil)                         // 18 = Indica pulo de linha após o campo (.T. ou .F.)
Return oViewTB1

//-------------------------------------------
/*/ Função fnV01SZN()
  Estrutura do detalhamento (View)
  						  
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-------------------------------------------
Static Function fnV01TB2()
  Local oViewSZN := FWFormViewStruct():New() 

  oViewSZN:AddField("ZN_STATUS",;                // 01 - Nome do Campo
                    "00",;                       // 02 - Ordem
                    "",;                         // 03 - Titulo do campo
                    "",;                         // 04 - Descrição do campo
                    {"Legenda"},;                // 05 - Array com Help
                    "C",;                        // 06 - Tipo do campo
                    "@BMP",;                     // 07 - Picture
                    Nil,;                        // 08 - Bloco de Picture Var
                    "",;                         // 09 - Consulta F3
                    .T.,;                        // 10 - Indica se o campo é alteravel
                    Nil,;                        // 11 - Pasta do campo
                    Nil,;                        // 12 - Agrupamento do campo
                    Nil,;                        // 13 - Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 - Tamanho maximo da maior opção do combo
                    Nil,;                        // 15 - Inicializador de Browse
                    .T.,;                        // 16 - Indica se o campo é virtual
                    Nil,;                        // 17 - Picture Variavel
                    Nil)                         // 18 - Indica pulo de linha após o campo

  oViewSZN:AddField("ZN_DATA",;                  // 01 - Nome do Campo
                    "02",;                       // 02 - Ordem
                    "Processamento",;            // 03 - Título do campo
                    "Processamento",;            // 04 - Descrição do campo
                    Nil,;                        // 05 - Array com Help
                    "D",;                        // 06 - Tipo do campo
                    "@!",;                       // 07 - Picture
                    Nil,;                        // 08 - Bloco de PictTre Var
                    "",;                         // 09 - Consulta F3
                    .F.,;                        // 10 - Indica se o campo é alterável
                    Nil,;                        // 11 - Pasta do Campo
                    Nil,;                        // 12 - Agrupamnento do campo
                    Nil,;                        // 13 - Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 - Tamanho máximo da opção do combo
                    Nil,;                        // 15 - Inicializador de Browse
                    .F.,;                        // 16 - Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 - Picture Variavel
                    Nil)                         // 18 - Indica pulo de linha após o campo (.T. ou .F.)

  oViewSZN:AddField("ZN_HORA",;                  // 01 - Nome do Campo
                    "03",;                       // 02 - Ordem
                    "Hora",;                     // 03 - Título do campo
                    "Hora",;                     // 04 - Descrição do campo
                    Nil,;                        // 05 - Array com Help
                    "C",;                        // 06 - Tipo do campo
                    "@!",;                       // 07 - Picture
                    Nil,;                        // 08 - Bloco de PictTre Var
                    "",;                         // 09 - Consulta F3
                    .T.,;                        // 10 - Indica se o campo é alteravel
                    Nil,;                        // 11 - Pasta do Campo
                    Nil,;                        // 12 - Agrupamnento do campo
                    Nil,;                        // 13 - Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 - Tamanho máximo da opção do combo
                    Nil,;                        // 15 - Inicializador de Browse
                    .F.,;                        // 16 - Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 - Picture Variavel
                    Nil)                         // 18 - Indica pulo de linha após o campo (.T. ou .F.)

  oViewSZN:AddField("ZN_CARGA",;                 // 01 - Nome do Campo
                    "04",;                       // 02 - Ordem
                    "Carga",;                    // 03 - Título do campo
                    "Carga",;                    // 04 - Descrição do campo
                    Nil,;                        // 05 - Array com Help
                    "C",;                        // 06 - Tipo do campo
                    "@!",;                       // 07 - Picture
                    Nil,;                        // 08 - Bloco de PictTre Var
                    "",;                         // 09 - Consulta F3
                    .T.,;                        // 10 - Indica se o campo é alterável
                    Nil,;                        // 11 - Pasta do Campo
                    Nil,;                        // 12 - Agrupamnento do campo
                    Nil,;                        // 13 - Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 - Tamanho máximo da opção do combo
                    Nil,;                        // 15 - Inicializador de Browse
                    .F.,;                        // 16 - Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 - Picture Variavel
                    Nil)                         // 18 - Indica pulo de linha após o campo (.T. ou .F.)
  
  oViewSZN:AddField("ZN_DTCARGA",;               // 01 - Nome do Campo
                    "05",;                       // 02 - Ordem
                    "Data Carga",;               // 03 - Título do campo
                    "Data Carga",;               // 04 - Descrição do campo
                    Nil,;                        // 05 - Array com Help
                    "D",;                        // 06 - Tipo do campo
                    "",;                         // 07 - Picture
                    Nil,;                        // 08 - Bloco de PictTre Var
                    "",;                         // 09 - Consulta F3
                    .F.,;                        // 10 - Indica se o campo é alterável
                    Nil,;                        // 11 - Pasta do Campo
                    Nil,;                        // 12 - Agrupamnento do campo
                    Nil,;                        // 13 - Lista de valores permitido do campo (Combo)
                    Nil,;                        // 14 - Tamanho máximo da opção do combo
                    Nil,;                        // 15 - Inicializador de Browse
                    .F.,;                        // 16 - Indica se o campo é virtual (.T. ou .F.)
                    Nil,;                        // 17 - Picture Variavel
                    Nil)                         // 18 - Indica pulo de linha após o campo (.T. ou .F.)
Return oViewSZN

//-----------------------------------------
/*/ fnF01MSG
  Campos de livres

  @parâmetro oPanel = campo será mostrado
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-----------------------------------------
Static Function fnF01MSG(oPanel)
  oBtMsg := TButton():New(05,10,">>",oPanel,{|| fnF01Det()},15,14,,,,.T.,,"",,,,.F. )
Return

//-----------------------------------------
/*/ fnF01Det
  Monstrar campo de mensagem

  @parâmetro oPanel = campo será mostrado
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-----------------------------------------
Static Function fnF01Det()
  Local oView   := FWViewActive()
  Local oModel  := FWModelActive()
  Local oGrdDet := oModel:GetModel("DETTB2")
  Local oGrdReg := oModel:GetModel("MSTZ01")

  dbSelectArea("Z01")
  Z01->(dbGoto(oGrdDet:GetValue("Z01_RECNO")))

  oGrdReg:LoadValue("ZN_DATA"   , Z01->Z01_DATA)
  oGrdReg:LoadValue("ZN_HORA"   , Z01->Z01_HORA)
  oGrdReg:LoadValue("ZN_CARGA"  , Z01->Z01_CARGA)
  oGrdReg:LoadValue("ZN_DTCARGA", Z01->Z01_DTCARGA)
  oGrdReg:LoadValue("ZN_MENSAG" , Z01->Z01_MENSAG)

  oView:Refresh()
Return

//-----------------------------------------
/*/ fnF01BTN
  Campo de funcionalidade

  @parâmetro oPanel = campo será mostrado
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-----------------------------------------
Static Function fnF01BTN(oPanel,oView)
  oPanelBt := TPanel():New(00,01,"",oPanel,,.T.,,CLR_YELLOW,,665,25,.T.,.F.)

  TButton():New(005,615,"Pesquisar",oPanelBt,{|| MsAguarde({|| fnF01REG(oView)},"Gerando...")},;
                                           40,15,,,.F.,.T.,.F.,,.F.,,,.F.)
Return

//-----------------------------------------
/*/ fnF01REG
  Montagem da tela de consulta

  @parâmetro oView = campo será mostrado
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2021	
/*/
//-----------------------------------------
Static Function fnF01REG(oView)
  Local cQuery  := ""
  Local oModel  := FWModelActive()
  Local oCpoCab := oModel:GetModel("MSTTB1")
  Local oGrdDet := oModel:GetModel("DETTB2")
  Local dInicio := IIf(Empty(DToS(oCpoCab:GetValue("T1_INICIO"))),dDataBase,oCpoCab:GetValue("T1_INICIO"))
  Local dFim    := IIf(Empty(DToS(oCpoCab:GetValue("T1_FIM"))),dDataBase,oCpoCab:GetValue("T1_FIM"))
  Local cCarga  := oCpoCab:GetValue("T1_CARGA")

  oModel:GetModel("DETTB2"):SetNoInsertLine(.F.) 
  oModel:GetModel("DETTB2"):SetNoUpdateLine(.F.) 
  oModel:GetModel("DETTB2"):SetNoDeleteLine(.F.)

  oModel:GetModel("DETTB2"):ClearData(.T.)

  cQuery := "Select Z01.Z01_STATUS, Z01.Z01_DATA, Z01.Z01_HORA, Z01.Z01_CARGA,"
  cQuery += "       Z01.Z01_DTCARGA, Z01.R_E_C_N_O_ as RECNO"
  cQuery += "  from " + RetSqlName("Z01") + " Z01"
  cQuery += "   where Z01.D_E_L_E_T_ <> '*'"
  cQuery += "     and Z01.Z01_FILIAL  = '" + FWxFilial("Z01") + "'"
  cQuery += "     and Z01.Z01_DATA between '" + DToS(dInicio) + "' and '" + DToS(dFim) + "'"

  If ! Empty(cCarga)
     cQuery += " and Z01.Z01_CARGA = '" + cCarga + "'"
  EndIf
  
  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TopConn",TcGenQry(,,cQuery),"QREG",.F.,.T.)

  If QREG->(Eof())
     Help(,,"HELP",,"Não existe registros.",1,0)

     oView:Refresh()

     QREG->(dbCloseArea())

     Return
  EndIf

  aMensag := {}

  While ! QREG->(Eof())
    aAdd(aMensag, QREG->RECNO)

    oGrdDet:AddLine()
        
    oGrdDet:LoadValue("ZN_STATUS" , IIf(QREG->Z01_STATUS == "S","BR_VERDE","BR_VERMELHO"))
    oGrdDet:LoadValue("ZN_DATA"   , SToD(QREG->Z01_DATA))
    oGrdDet:LoadValue("ZN_HORA"   , QREG->Z01_HORA)
    oGrdDet:LoadValue("ZN_CARGA"  , QREG->Z01_CARGA)
    oGrdDet:LoadValue("ZN_DTCARGA", SToD(QREG->Z01_DTCARGA))
    oGrdDet:LoadValue("ZN_RECNO"  , QREG->RECNO)

    QREG->(dbSkip())
  EndDo

  oGrdDet:GoLine(1)

  oModel:GetModel("DETTB2"):SetNoInsertLine(.T.) 
  oModel:GetModel("DETTB2"):SetNoUpdateLine(.T.) 
  oModel:GetModel("DETTB2"):SetNoDeleteLine(.T.)

  oView:Refresh()

  QREG->(dbCloseArea())
Return

//-------------------------------------------------------------------
/*/ fnF01FEC
  Campo e botão para fechar tela

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since   25/05/2021	
/*/
//-------------------------------------------------------------------
Static Function fnF01FEC()
  Local oView := FWViewActive()

  oView:ButtonCancelAction()
Return

//-------------------------------------------------------------------
/*/ Função: fnL01LEG()
  Define a legenda da tela
  						  
  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since	25/05/2020	
/*/
//-------------------------------------------------------------------
Static Function fnL01LEG() 
  Local aLegenda := {}

  aAdd(aLegenda, {"BR_VERMELHO","Erro Integração"})
  aAdd(aLegenda, {"BR_VERDE"   ,"Sucesso"})

  BrwLegenda("Log","Legenda",aLegenda) 
Return
