#Include "Protheus.ch"
#Include "FWMVCDEF.ch"
#Include "TOPCONN.ch"

//-------------------------------------------------------------------
/*/ Rotina FFFATC02
  
    Consulta Pedido de Venda e suas cargas.

  @author Anderson Almeida (Totvs Ne)
  @since   28/08/2024 - Desenvolvimento da Rotina.
/*/
//-------------------------------------------------------------------
User Function FFFATC02()
  Local aCampos  := {}
  Local aButtons := {{.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,""},;
                     {.T.,"Fechar"},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,Nil},;
                     {.F.,NIl}}

  Private nTamPFus := TamSX3("C9_PEDIDO")[1] + TamSX3("C9_XSEQFUS")[1]

  nTamPFus := IIf(nTamPFus < 11,11,nTampFus)
  
 // -- Criação da tabela temporária
 // -------------------------------
  aAdd(aCampos,{"T1_PEDIDO" ,"C",TamSX3("C9_PEDIDO")[1],0})
  aAdd(aCampos,{"T1_CLIENTE","C",TamSX3("A1_COD")[1],0})
  aAdd(aCampos,{"T1_LOJA"   ,"C",TamSX3("A1_LOJA")[1],0})
  aAdd(aCampos,{"T1_NOME"   ,"C",TamSX3("A1_NOME")[1],0})
  aAdd(aCampos,{"T1_EMISSAO","D",8,0})

  oTempTCAB := FWTemporaryTable():New("TCAB")
  oTempTCAB:SetFields(aCampos)
  oTempTCAB:AddIndex("01", {"T1_PEDIDO"})
  oTempTCAB:Create()

  aCampos := {} 

  aAdd(aCampos,{"T2_STATUS" ,"C",15,0})
  aAdd(aCampos,{"T2_PEDIDO" ,"C",TamSX3("C9_PEDIDO")[1],0})
  aAdd(aCampos,{"T2_ITEM"   ,"C",2,0})
  aAdd(aCampos,{"T2_XSEQFUS","C",TamSX3("C9_XSEQFUS")[1],0})
  aAdd(aCampos,{"T2_PEDFUS" ,"C",nTamPFus,0})
  aAdd(aCampos,{"T2_CARGA"  ,"C",TamSX3("C9_CARGA")[1],0})
  aAdd(aCampos,{"T2_ENTREGA","D",8,0})

  oTempTCRG := FWTemporaryTable():New("TCRG")
  oTempTCRG:SetFields(aCampos)
  oTempTCRG:AddIndex("01", {"T2_PEDIDO","T2_ITEM","T2_XSEQFUS"})
  oTempTCRG:Create()

  aCampos := {}

  aAdd(aCampos,{"T3_XSEQFUS","C",TamSX3("C9_XSEQFUS")[1],0})
  aAdd(aCampos,{"T3_ITEM"   ,"C",2,0})
  aAdd(aCampos,{"T3_PRODUTO","C",TamSX3("B1_COD")[1],0})
  aAdd(aCampos,{"T3_DESC"   ,"C",TamSX3("B1_DESC")[1],0})
  aAdd(aCampos,{"T3_QTDE"   ,"N",TamSX3("C9_QTDLIB")[1],TamSX3("C9_QTDLIB")[2]})
  aAdd(aCampos,{"T3_TOTAL"  ,"N",TamSX3("C9_PRCVEN")[1],TamSX3("C9_PRCVEN")[2]})
  aAdd(aCampos,{"T3_NFISCAL","C",TamSX3("C9_NFISCAL")[1],0})
  aAdd(aCampos,{"T3_SERIENF","C",TamSX3("C9_SERIENF")[1],0})

  oTempTPED := FWTemporaryTable():New("TPED")
  oTempTPED:SetFields(aCampos)
  oTempTPED:AddIndex("01", {"T3_XSEQFUS","T3_ITEM","T3_PRODUTO"})
  oTempTPED:Create()

  FWExecView("Consulta Pedido x Carga","PFATF003",MODEL_OPERATION_INSERT,,{|| .T.},,50,aButtons)

  oTempTCAB:Delete()
  oTempTCRG:Delete()
  oTempTPED:Delete()  
Return 

//-------------------------------------------------------------------
/*/ Função ModelDef 

  Regra de negócio da tela.
  
  @author Anderson Almeida (TOTVS Ne)
  @since   28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function ModelDef() 
  Local oModel
  Local oStrCab := fn01MCAB()
  Local oStrCrg := fn01MCRG()
  Local oStrPed := fn01MPED()

  oModel := MPFormModel():New("Consulta Pedido x Carga",,,{|| })  

  oModel:SetDescription("Consulta Pedido x Carga")    

  oModel:AddFields("MSTCAB",,oStrCab)
  oModel:AddGrid("DETCRG","MSTCAB",oStrCrg,,,,,)
  oModel:AddGrid("DETPED","DETCRG",oStrPed,,,,,)

  oModel:AddCalc("TOTPED","DETCRG","DETPED","T3_TOTAL","TOTAL","SUM",{|| .T.},{|| 0},"Total Pedido",,12,2)
 
  oModel:SetPrimaryKey({""})

  oModel:GetModel("DETCRG"):SetNoInsertLine(.T.)
  oModel:GetModel("DETCRG"):SetNoUpdateLine(.T.)
  oModel:GetModel("DETCRG"):SetNoDeleteLine(.T.)

  oModel:GetModel("DETPED"):SetNoInsertLine(.T.)
  oModel:GetModel("DETPED"):SetNoUpdateLine(.T.)
  oModel:GetModel("DETPED"):SetNoDeleteLine(.T.)

  oModel:SetRelation("DETCRG",{{"T2_PEDIDO","T1_PEDIDO"},;
						         TCRG->(IndexKey(1))})

  oModel:SetRelation("DETPED",{{"T3_XSEQFUS","T2_XSEQFUS"},;
						         TPED->(IndexKey(1))})
Return oModel

//-------------------------------------------------------------------
/*/ Função fn01MCAB()

   Estrutura do detalhe do nome do arquivo a importar.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fn01MCAB()
  Local oStruct := FWFormModelStruct():New()
 
  oStruct:AddTable("TCAB",{"T1_PEDIDO"},"Pedido")
  oStruct:AddField("Pedido" ,"Pedido" ,"T1_PEDIDO" ,"C",TamSX3("C5_NUM")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Cliente","Cliente","T1_CLIENTE","C",TamSX3("A1_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Loja"   ,"Loja"   ,"T1_LOJA"   ,"C",TamSX3("A1_LOJA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Nome"   ,"Nome"   ,"T1_NOME"   ,"C",TamSX3("A1_NOME")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Emissão","Emissão","T1_EMISSAO","D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)

  oStruct:SetProperty("T1_PEDIDO",MODEL_FIELD_VALID,;
                      FWBuildFeature(STRUCT_FEATURE_VALID,"U_fn01VPV(FWFldGet('T1_PEDIDO'))"))

  oStruct:AddTrigger("T1_PEDIDO","T1_CLIENTE",{||.T.},{|oModel,cField,cVal| Posicione("SC9",1,FWxFilial("SC9") + cVal,"C9_CLIENTE")})
  oStruct:AddTrigger("T1_PEDIDO","T1_LOJA"   ,{||.T.},{|oModel,cField,cVal| Posicione("SC9",1,FWxFilial("SC9") + cVal,"C9_LOJA")})
  oStruct:AddTrigger("T1_PEDIDO","T1_NOME"   ,{||.T.},{|oModel,cField,cVal| fnF03Ped(oModel,cVal,"N")})
  oStruct:AddTrigger("T1_PEDIDO","T1_EMISSAO",{||.T.},{|oModel,cField,cVal| fnF03Ped(oModel,cVal,"E")})
Return oStruct

//-------------------------------------------------------------------
/*/ Função fnF03Ped()

    Pegar campo do cabeçalho								  

  @author Anderson Almeida (TOTVS NE)
  @since	 28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fnF03Ped(oModel,cVal,cCampo)
  Local xRet

  If cCampo == "N"
     dbSelectArea("SC9")
     SC9->(dbSetOrder(1))

     If SC9->(dbSeek(FWxFilial("SC9") + cVal))
        xRet := Posicione("SA1",1,FWxFilial("SA1") + SC9->C9_CLIENTE + SC9->C9_LOJA,"A1_NOME") 
      else
        Help(,,"HELP",,"Pedido não cadastrado.",1,0)
     EndIf

   elseIf cCampo == "E" 
          xRet := Posicione("SC5",1,FWxFilial("SC5") + cVal,"C5_EMISSAO") 
  EndIf         
Return xRet

//-------------------------------------------------------------------
/*/ Função fn01MCRG()
  
   Estrutura do detalhe do grid de Carga.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fn01MCRG()
  Local oStruct := FWFormModelStruct():New()
 
  oStruct:AddTable("TCRG",{"T2_PEDIDO","T2_CARGA"},"Carga")
  oStruct:AddField(""       ,""       ,"T2_STATUS" ,"C",15,0,Nil,Nil,{},.F.,,.F.,.F.,.T.)
  oStruct:AddField("Pedido" ,"Pedido" ,"T2_PEDIDO" ,"C",TamSX3("C5_NUM")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Seq"    ,"Seq"    ,"T2_XSEQFUS","C",TamSX3("C5_XSEQFUS")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Item"   ,"Item"   ,"T2_ITEM"   ,"C",2,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("FUSION" ,"FUSION" ,"T2_PEDFUS" ,"C",nTamPFus,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Carga"  ,"Carga"  ,"T2_CARGA"  ,"C",TamSX3("C9_CARGA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Entrega","Entrega","T2_ENTREGA","D",8,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------------------------------
/*/ Função fn01MPED()
  
   Estrutura do detalhe do grid de Carga.

  @author Anderson Almeida (TOTVS NE)
  @since   28/08/2024
/*/
//-------------------------------------------------------------------
Static Function fn01MPED()
  Local oStruct := FWFormModelStruct():New()
 
  oStruct:AddTable("TPED",{"T3_CARGA","T3_ITEM"},"Pedido")
  oStruct:AddField("FUSION"     ,"FUSION"     ,"T3_XSEQFUS","C",TamSX3("C9_CARGA")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Item"       ,"Item"       ,"T3_ITEM"   ,"C",2,0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Produto"    ,"Produto"    ,"T3_PRODUTO","C",TamSX3("B1_COD")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Descrição"  ,"Descrição"  ,"T3_DESC"   ,"C",TamSX3("B1_DESC")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Quantidade" ,"Quantidade" ,"T3_QTDE"   ,"N",TamSX3("C9_QTDLIB")[1],TamSX3("C9_QTDLIB")[2],Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Total"      ,"Total"      ,"T3_TOTAL"  ,"N",TamSX3("C9_PRCVEN")[1],TamSX3("C9_PRCVEN")[2],Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Nota Fiscal","Nota Fiscal","T3_NFISCAL","C",TamSX3("C9_NFISCAL")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
  oStruct:AddField("Serie NF"   ,"Serie NF"   ,"T3_SERIENF","C",TamSX3("C9_SERIENF")[1],0,Nil,Nil,{},.F.,,.F.,.F.,.F.)
Return oStruct

//-------------------------------------------------------------------
/*/ Função ViewDef()
  
   Definição da View

  @author Anderson Almeida - TOTVS
  @since   28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function ViewDef() 
  Local oModel  := ModelDef() 
  Local oStrCab := fn01VCab()
  Local oStrCrg := fn01VCrg()
  Local oStrPed := fn01VPed()
  Local oTotPed := FWCalcStruct(oModel:GetModel("TOTPED"))
  Local oView

  oView := FWFormView():New() 
   
  oView:SetModel(oModel)    

  oView:AddField("FCAB",oStrCab,"MSTCAB") 
  oView:AddGrid("FCRG" ,oStrCrg,"DETCRG")
  oView:AddGrid("FPED" ,oStrPed,"DETPED")
  oView:AddField("TPED",oTotPed,"TOTPED")
  
  oView:AddUserButton("Legenda"     ,"btLeg"    ,{|| FSF03LEG()},"Legenda"     ,,)
  oView:AddUserButton("Envio FUSION","MAGIC_BMP",{|| FSF03ENV()},"Envio FUSION",,)
  
  oView:AddIncrementField("FPED","T3_ITEM")

 // --- Definição da Tela
 // ---------------------
  oView:CreateHorizontalBox("HBXFIL",37)

  oView:CreateHorizontalBox("HBXREG",63)
  oView:CreateVerticalBox("VBXCRG",25,"HBXREG")

  oView:CreateVerticalBox("VBXPED",75,"HBXREG") 
  oView:CreateHorizontalBox("HBXPED",77,"VBXPED")
  oView:CreateHorizontalBox("HBXTOT",23,"VBXPED")

 // --- Definição dos campos
 // ------------------------    
  oView:SetOwnerView("FCAB","HBXFIL")
  oView:SetOwnerView("FCRG","VBXCRG")
  oView:SetOwnerView("FPED","HBXPED")
  oView:SetOwnerView("TPED","HBXTOT")

  oView:SetViewAction("ASKONCANCELSHOW",{|| .F.})          // Tirar a mensagem do final "Há Alterações não..."
Return oView

//-------------------------------------------------------------------
/*/ Função: FSF03LEG()

   Define a legenda da tela
  						  
  @author Anderson Almeida (TOTVS NE)
  @since	28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function FSF03LEG() 
  Local aLegenda := {}

  aAdd(aLegenda, {"BR_VERDE"   ,"Aberto"})
  aAdd(aLegenda, {"BR_AZUL"    ,"Não Enviado"})
  aAdd(aLegenda, {"BR_VERMELHO","Encerrado"})

  BrwLegenda("Pedido x FUSION","Legenda",aLegenda) 
Return

//-------------------------------------------------------------------
/*/ Função: FSF03ENV()

   Chamada da função de Envio para FUSION
  						  
  @author Anderson Almeida (TOTVS NE)
  @since	 28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function FSF03ENV()
  Local oModel  := FWModelActive()
  Local oGrdCrg := oModel:GetModel("DETCRG")

  If ! Empty(oGrdCrg:GetValue("T2_CARGA"))
     Help(" ",1,"ATENÇÃO",,"Pedido encontra-se em Carga.",3,1,,,,,,{"",""})

   elseIf ApMsgYesNo("Deseja reenviar o Pedido " + AllTrim(oGrdCrg:GetValue("T2_PEDIDO")) +;
                     " com a sequência " + AllTrim(oGrdCrg:GetValue("T2_XSEQFUS")) + " para o FUSION ?","ATENÇÃO")
          dbSelectArea("SC5")
          SC5->(dbSetOrder(1))

          U_PFAT0016({oGrdCrg:GetValue("T2_PEDIDO"),oGrdCrg:GetValue("T2_XSEQFUS")})
  EndIf
Return

//-------------------------------------------------------------------
/*/ Função fn01VCab()

  Estrutura do cabeçalho, campos para filtro
  						  
  @author Anderson Almeida - TOTVS
  @since  28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fn01VCab()
  Local oViewCab := FWFormViewStruct():New()
  
 // -- Montagem Estrutura
 //      01 = Nome do Campo
 //      02 = Ordem
 //      03 = Título do campo
 //      04 = Descrição do campo
 //      05 = Array com Help
 //      06 = Tipo do campo
 //      07 = Picture
 //      08 = Bloco de PictTre Var
 //      09 = Consulta F3
 //      10 = Indica se o campo é alterável
 //      11 = Pasta do Campo
 //      12 = Agrupamnento do campo
 //      13 = Lista de valores permitido do campo (Combo)
 //      14 = Tamanho máximo da opção do combo
 //      15 = Inicializador de Browse
 //      16 = Indica se o campo é virtual (.T. ou .F.)
 //      17 = Picture Variavel
 //      18 = Indica pulo de linha após o campo (.T. ou .F.)
 // ---------------------------------------------------------

  oViewCab:AddField("T1_PEDIDO" ,"01","Pedido" ,"Pedido" ,Nil,"C","@!",Nil,"SC5",.T.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCab:AddField("T1_CLIENTE","02","Cliente","Cliente",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,Nil,Nil,Nil)
  oViewCab:AddField("T1_LOJA"   ,"03","Loja"   ,"Loja"   ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCab:AddField("T1_NOME"   ,"04","Nome"   ,"Nome"   ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCab:AddField("T1_EMISSAO","05","Emissão","Emissão",Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewCab

//-------------------------------------------------------------------
/*/ Função fn01VCrg()
  Estrutura do grid de Carga
  						  
  @author Anderson Almeida (TOTVS NE)
  @version P12.1...
  @since  28/01/2022	
/*/
//-------------------------------------------------------------------
Static Function fn01VCrg()
  Local oViewCrg := FWFormViewStruct():New()
  
  oViewCrg:AddField("T2_STATUS" ,"00",""         ,""         ,{"Legenda"},"C","@BMP",Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCrg:AddField("T2_PEDFUS" ,"01","FUSION"   ,"FUSION"   ,Nil        ,"C","@!"  ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCrg:AddField("T2_CARGA"  ,"02","Carga"    ,"Carga"    ,Nil        ,"C","@!"  ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewCrg:AddField("T2_ENTREGA","03","Encerrada","Encerrada",Nil        ,"C","@!"  ,Nil,Nil,.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewCrg

//-------------------------------------------------------------------
/*/ Função fn01VPed()
  Estrutura do grid de Pedido de Venda
  						  
  @author Anderson Almeida (TOTVS NE)
  @version P12.1...
  @since  28/01/2022	
/*/
//-------------------------------------------------------------------
Static Function fn01VPed()
  Local oViewPed := FWFormViewStruct():New()
  
  oViewPed:AddField("T3_ITEM"   ,"01","Item"      ,"Item"      ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_PRODUTO","02","Produto"   ,"Produto"   ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_DESC"   ,"03","Descrição" ,"Descrição" ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_QTDE"   ,"04","Quantidade","Quantidade",Nil,"N","@E 99,999.9999"   ,Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_TOTAL"  ,"05","Total"     ,"Total"     ,Nil,"N","@E 999,999,999.99",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_NFISCAL","06","NFe"       ,"NFe"       ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
  oViewPed:AddField("T3_SERIENF","07","Serie"     ,"Serie"     ,Nil,"C","@!",Nil,"",.F.,Nil,Nil,Nil,Nil,Nil,.F.,Nil,Nil)
Return oViewPed

//---------------------------------------------------------------
/*/ Função fn01VPV()

  Validar o Pedido de Venda.

  @author Anderson Almeida (TOTVS NE)
  @version P12.1.17
  @since  20/08/2021	
/*/
//---------------------------------------------------------------
User Function fn01VPV(pPedido)
  Local oModel  := FWModelActive()
  Local oView   := FWViewActive()
  Local oGrdCrg := oModel:GetModel("DETCRG")
  Local oGrdPed := oModel:GetModel("DETPED")
  Local oTotPed := oModel:GetModel("TOTPED")
  Local lRet    := .T.
  Local cQuery  := ""
  Local cSeqFus := ""
  Local nTotPed := 0

  oGrdCrg:ClearData(.T.)
  oGrdPed:ClearData(.T.)

  oGrdCrg:SetNoInsertLine(.F.)
  oGrdCrg:SetNoUpdateLine(.F.)

  oGrdPed:SetNoInsertLine(.F.)
  oGrdPed:SetNoUpdateLine(.F.)

  cQuery := "Select SC9.C9_PEDIDO, SC9.C9_CLIENTE, SC9.C9_LOJA, SC9.C9_PRODUTO, SC9.C9_QTDLIB, SA1.A1_NOME,"
  cQuery += "       SC9.C9_PRCVEN, SC9.C9_NFISCAL, SC9.C9_SERIENF, SC9.C9_CARGA, SB1.B1_DESC, SC5.C5_EMISSAO,"
  cQuery += "       Case When SC5.C5_XSEQFUS = '' then '' else SC9.C9_XSEQFUS end SEQFUS,"
  cQuery += "       Case When SC9.C9_CARGA <> '' then (Select DAK.DAK_DTACCA from " + RetSqlName("DAK") + " DAK"
  cQuery += "                                       where DAK.D_E_L_E_T_ <> '*'"
  cQuery += "                                         and DAK.DAK_FILIAL  = '" + FWxFilial("DAK") + "'"
  cQuery += "                                         and DAK.DAK_COD     = SC9.C9_CARGA)"
  cQuery += "                               else '' end ENTREGA"
  cQuery += "  from " + RetSqlName("SC9") + " SC9, " + RetSqlName("SC5") + " SC5, "
  cQuery += RetSqlName("SA1") + " SA1, " + RetSqlName("SB1") + " SB1"
  cQuery += "   where SC9.D_E_L_E_T_ <> '*'"
  cQuery += "     and SC9.C9_FILIAL  = '" + FWxFilial("SC9") + "'"
  cQuery += "     and SC9.C9_PEDIDO  = '" + pPedido + "'"
  cQuery += "     and SC5.D_E_L_E_T_ <> '*'"
  cQuery += "     and SC5.C5_FILIAL  = '" + FWxFilial("SC5") + "'"
  cQuery += "     and SC5.C5_NUM     = SC9.C9_PEDIDO"
  cQuery += "     and SC5.C5_TPCARGA = '1'"
  cQuery += "     and SA1.D_E_L_E_T_ <> '*'"
  cQuery += "     and SA1.A1_FILIAL  = '" + FWxFilial("SA1") + "'"
  cQuery += "     and SA1.A1_COD     = SC9.C9_CLIENTE"
  cQuery += "     and SA1.A1_LOJA    = SC9.C9_LOJA"
  cQuery += "     and SB1.D_E_L_E_T_ <> '*'"
  cQuery += "     and SB1.B1_FILIAL  = '" + FWxFilial("SB1") + "'"
  cQuery += "     and SB1.B1_COD     = SC9.C9_PRODUTO"
  cQuery += "  Order By SC9.C9_XSEQFUS"
  cQuery := ChangeQuery(cQuery)
  dbUseArea(.T.,"TopConn",TCGenQry(,,cQuery),"QPED",.F.,.T.)

  If QPED->(Eof())
     Help(" ",1,"ATENÇÃO",,"Pedido de Venda não cadastrado ou não monta Carga.",3,1,,,,,,{"",""})

     lRet := .F.
   else
    While ! QPED->(Eof())
       If cSeqFus <> QPED->SEQFUS
          oGrdCrg:AddLine()

          oGrdCrg:LoadValue("T2_STATUS" , IIf(Empty(QPED->ENTREGA),"BR_VERDE","BR_VERMELHO"))
          oGrdCrg:LoadValue("T2_PEDIDO" , pPedido)
          oGrdCrg:LoadValue("T2_XSEQFUS", QPED->SEQFUS)
          oGrdCrg:LoadValue("T2_PEDFUS" , IIf(Empty(QPED->SEQFUS),pPedido,(pPedido + "_" + AllTrim(QPED->SEQFUS))))
          oGrdCrg:LoadValue("T2_CARGA"  , QPED->C9_CARGA)
          oGrdCrg:LoadValue("T2_ENTREGA", IIf(Empty(QPED->ENTREGA),"",SToD(QPED->ENTREGA)))

          cSeqFus := QPED->SEQFUS
          nTotPed := 0
       EndIf   

       oGrdPed:AddLine()

       oGrdPed:LoadValue("T3_XSEQFUS", QPED->SEQFUS)
       oGrdPed:LoadValue("T3_PRODUTO", QPED->C9_PRODUTO)
       oGrdPed:LoadValue("T3_DESC"   , QPED->B1_DESC)
       oGrdPed:LoadValue("T3_QTDE"   , QPED->C9_QTDLIB)
       oGrdPed:LoadValue("T3_TOTAL"  , (QPED->C9_QTDLIB * QPED->C9_PRCVEN))
       oGrdPed:LoadValue("T3_NFISCAL", QPED->C9_NFISCAL)
       oGrdPed:LoadValue("T3_SERIENF", QPED->C9_SERIENF)

       nTotPed += QPED->C9_QTDLIB * QPED->C9_PRCVEN
       
       oTotPed:LoadValue("TOTAL", nTotPed)
       
       QPED->(dbSkip())
     EndDo

     QPED->(dbCloseArea())

     oGrdCrg:GoLine(1)
     oGrdPed:GoLine(1)
  EndIf

  oGrdCrg:SetNoInsertLine(.T.)
  oGrdCrg:SetNoUpdateLine(.T.)

  oGrdPed:SetNoInsertLine(.T.)
  oGrdPed:SetNoUpdateLine(.T.)

  oView:Refresh()
Return lRet  
