#Include "PROTHEUS.ch"
#Include "FWMVCDEF.ch"

// ----------------------------------------------------
/*/ Rotina FFFATC03

    Cadastro de Rota de entrega do FUSION. 

  @param Não há
  @retorno Confirmação
  @author Anderson Almeida (TOTVS)
  @since 17/09/2024 - Desenvolvimento da Rotina.
/*/
// ----------------------------------------------------
User Function FFFATC03()
  Local oBrowse

  Private cCadastro := "Rota Entrega FUSION"	
  
  oBrowse := FWMBrowse():New()
  
  oBrowse:SetAlias("Z02")
  oBrowse:SetDescription("Rota Entrega FUSION")
  oBrowse:Activate()
Return

// ----------------------------------------------------
/*/ Função MenuDef

   Define as operações quer serão realizadas.

  @author Anderson Almeida (TOTVS)
  @since 17/09/2024
/*/
// ----------------------------------------------------   
Static Function MenuDef()
  Local aRotina := {}

  Add Option aRotina Title "Visualizar" Action "VIEWDEF.FFFATC03" Operation 2 Access 0
  Add Option aRotina Title "Incluir"    Action "VIEWDEF.FFFATC03" Operation 3 Access 0
  Add Option aRotina Title "Alterar"    Action "VIEWDEF.FFFATC03" Operation 4 Access 0
  Add Option aRotina Title "Excluir"    Action "VIEWDEF.FFFATC03" Operation 5 Access 0
  Add Option aRotina Title "Imprimir"   Action "VIEWDEF.FFFATC03" Operation 8 Access 0
Return aRotina

// ----------------------------------------------------
/*/ Função ModelDef

   Define as regras de negocio.

  @author Anderson Almeida (TOTVS)
  @since 17/09/2024
/*/
// ----------------------------------------------------   
Static Function ModelDef()
  Local oModel
  Local oStruZ02 := FWFormStruct(1,"Z02")

  oModel := MPFormModel():New("CAD_ROTA",,{|oModel| fnVldGrv(oModel)})
  
  oModel:SetDescription("Rota FUSION")
  oModel:AddFields("MSTZ02",,oStruZ02)

  oModel:SetPrimaryKey({"Z02_COD"})
Return oModel

// -----------------------------------------------------
/*/ Função fnVldGrv

   Define toda a parte visual da aplicação.

  @author Anderson Almeida (TOTVS)
  @since 17/09/2024 
/*/
// -----------------------------------------------------  
Static Function fnVldGrv(oModel)
  Local lRet   := .T.
  Local cQuery := ""
  Local nOper  := oModel:GetOperation()

  If nOper == 5
     cQuery := "Select SA1.A1_XROTA"
     cQuery += " from " + RetSqlName("SA1") + " SA1"
     cQuery += "  Where SA1.D_E_L_E_T_ <> '*'"
     cQuery += "    and SA1.A1_FILIAL  = '" + FWxFilial("SA1") + "'"
     cQuery += "    and SA1.A1_XROTA   = '" + oModel:GetValue("MSTZ02","Z02_COD") + "'"
     cQuery := ChangeQuery(cQuery)
     dbUseArea(.T.,"TopConn",TcGenQry(,,cQuery),"QSA1",.F.,.T.)
               
     If ! QSA1->(Eof())
        Help(,,"HELP",,"Exclusão não permitida, Rota associada ao cliente " + QSZ4->A1_NREDUZ + ".",1,0)

        lRet := .F.
     EndIf
               
     QSA1->(dbCloseArea())
  EndIf
Return lRet

// ----------------------------------------------------
/*/ Função ViewDef

   Define toda a parte visual da aplicação.

  @author Anderson Almeida (TOTVS)
  @since 18/09/2024 
/*/
// -----------------------------------------------------
Static Function ViewDef()
  Local oModel  := ModelDef()
  Local oStrZ02 := FWFormStruct(2,"Z02")
  Local oView
  
  oView := FWFormView():New()
  
  oView:SetModel(oModel)

  oView:AddField("FCAD", oStrZ02,"MSTZ02") 
  oView:CreateHorizontalBox("BXCAB", 100)
  oView:SetOwnerView("FCAD","BXCAB")
Return oView
