#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE 'Protheus.ch'
#INCLUDE 'FWMVCDef.ch'

/*/{Protheus.doc} xAlteraDado
  Carga de dados para alteração
  @type Function de Usuario
  @author TOTVS Recife (Elvis Siqueira)
  @since 21/08/2023
  @version 1.0
  /*/

User Function xAlteraDado2()
Local oDialog, oPanel, oTSay, oCombo, oDlg
Local aTabelas := {"SB1 - Produtos","SA1 - Clientes","SA2 - Fornecedores","SB5 - Complemento do Produto"}

Private cTabela := ""

oDialog := FWDialogModal():New()
oDialog:SetBackground( .T. ) 
oDialog:SetTitle( 'Preencha os parâmetros abaixo:' )
oDialog:SetSize( 140, 250 )
oDialog:EnableFormBar( .T. )
oDialog:SetCloseButton( .F. )
oDialog:SetEscClose( .F. )
oDialog:CreateDialog()
oDialog:CreateFormBar()
oDialog:AddCloseButton(Nil, "Confirmar")

oPanel := oDialog:GetPanelMain()

	oTSay  := TSay():New(10,5,{|| "Tabela: "},oPanel,,,,,,.T.,,,50,70,,,,,,.T.)
	oCombo := TComboBox():New(29,28,{|u|iif(PCount()>0,cTabela:=u,cTabela)},aTabelas,100,20,oDlg,,{||},,,,.T.,,,,,,,,,'cTabela')
  
  oTSay  := TSay():New(30,5,{|| "Observações da Rotina: "},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(40,5,{|| "Está rotina irá utilizar como chave os indices abaixo: "},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(48,20,{|| 'SB1 - Produtos (B1_COD - "Código")'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(56,20,{|| 'SA1 - Cliente (A1_COD+A1_LOJA - "Código+Loja")'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(64,20,{|| 'SA2 - Fornecedor (A2_COD+A2_LOJA - "Código+Loja")'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(72,20,{|| 'SB5 - Dados Adicionais do Produto (B5_COD - "Código")'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)
  oTSay  := TSay():New(84,5,{|| 'Os campos sitados acima deverão constar no arquivo para que seja possível o posicionamento no registro.'},oPanel,,,,,,.T.,,,200,50,,,,,,.T.)

oDialog:Activate()

cTabela := SubStr( cTabela, 1, At('-', cTabela) - 2)

Processa({|| xProcessa()}, "Integrando Registros...")

Return 

Static Function xProcessa()
Local aRegistro  := {}
Local aCabeca    := {}
Local aFieldsX3  := {}
Local aRetX3     := {}
Local nAtual     := 0
Local nFim       := 0
Local nPosField1 := 0
Local nPosField2 := 0
Local cArq       := ""
Local cLinha     := ""
Local cTipoX3    := ""
Local cQry       := ""
Local __cAlias   := "TMP"+FWTimeStamp(1)
Local nY

Private oModel := Nil
Private lMsErroAuto := .F.
Private aRotina := {}

cArq := TFileDialog( "CSV Files (*.csv) | Arquivo texto (*.txt)",,,, .F., /*GETF_MULTISELECT*/ )

If !File(cArq)
	Return
EndIf

DBSelectArea(cTabela)
&(cTabela)->(DBSetOrder(1))

FT_FUSE(cArq)
nFim := FT_FLASTREC()
ProcRegua(nFim)
FT_FGOTOP()

While !FT_FEOF()
		
    nAtual++
    IncProc("Gravando alteração " + cValToChar(nAtual) + " de " + cValToChar(nFim) + "...")

	cLinha := FT_FREADLN()
			
	If !Empty(cLinha)
		aRegistro := {}
		aRegistro := Separa(cLinha,";",.T.)
        
    If Empty(aCabeca)
      
      cQry := " SELECT SX3.X3_CAMPO, SX3.X3_TITULO " 
      cQry += " FROM "+ RetSqlName("SX3") +" SX3 "
      cQry += " WHERE SX3.D_E_L_E_T_ <> '*' "
      cQry += " AND	SX3.X3_ARQUIVO  = '"+cTabela+"' " 
      cQry += " ORDER BY X3_ORDEM "
      cQry := ChangeQuery(cQry)
      IF Select(__cAlias) <> 0
          (__cAlias)->(DbCloseArea())
      EndIf
      dbUseArea(.T.,"TOPCONN",TcGenQry(,,cQry),__cAlias,.T.,.T.)

      While!(__cAlias)->(EOF())

          aAdd(aFieldsX3,{Alltrim((__cAlias)->X3_CAMPO),Alltrim((__cAlias)->X3_TITULO)})

      (__cAlias)->(DBSkip())
      EndDo

      IF Select(__cAlias) <> 0
          (__cAlias)->(DbCloseArea())
      EndIf

      For nY := 1 To Len(aRegistro)
        nPosField1 := aScan(aFieldsX3, {|x| AllTrim(x[2]) == Alltrim(aRegistro[nY])})
        If !Empty(nPosField1)
          aRegistro[nY] := aFieldsX3[nPosField1,1]
        EndIf 
      Next nY

      aCabeca := aClone(aRegistro)
    
    Else 

      For nY := 1 To Len(aRegistro)
        aRetX3  := TamSX3(aCabeca[nY])
        If Len(aRetX3) > 0
          cTipoX3 := aRetX3[3]
          //Converte de Caracter para o tipo do campo da SX3
          If cTipoX3 == "N"
            aRegistro[nY] := {aCabeca[nY], Val(Pad(StrTran(aRegistro[nY],",","."), TamSx3(aCabeca[nY])[1])),Nil} //Converte p/ Númerico
          ElseIf cTipoX3 == "D"
            aRegistro[nY] := {aCabeca[nY], CToD(Pad(aRegistro[nY], TamSx3(aCabeca[nY])[1])),Nil} //Converte p/ Data
          ElseIf cTipoX3 $ ('C,M')
            aRegistro[nY] := {aCabeca[nY], Pad(aRegistro[nY], TamSx3(aCabeca[nY])[1]),Nil} //Não converte
          EndIf
        EndIf                 
      Next nY
        
      Do Case 
        Case cTabela == "SB1"
          nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "B1_COD"})
        
          If nPosField1 > 0
            If SB1->(MSseek(FWxFilial("SB1")+aRegistro[nPosField1,2]))
              /*
              lMsErroAuto := .F.
              oModel := FwLoadModel("MATA010")
              FWMVCRotAuto( oModel,"SB1",MODEL_OPERATION_UPDATE,{{"SB1MASTER", aRegistro}})
        
              If lMsErroAuto
              MostraErro()
              EndIf
			        */
              RecLock("SB1",.F.)
                For nY := 2 To Len(aRegistro)
                  &('SB1->'+aRegistro[nY,1]) := aRegistro[nY,2]
                Next
              SB1->(MSUnlock())
            EndIF 
          EndIf 
        
        Case cTabela == "SA1"
        
          nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "A1_COD"})
          nPosField2 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "A1_LOJA"})
        
          If nPosField1 > 0 .And. nPosField2 > 0
            If SA1->(MSseek(FWxFilial("SA1")+aRegistro[nPosField1,2]+aRegistro[nPosField2,2]))
              /*
              lMsErroAuto := .F.
              oModel := FwLoadModel("CRMA980")
              FWMVCRotAuto( oModel,"SA1",MODEL_OPERATION_UPDATE,{{"SA1MASTER", aRegistro}})
          
              If lMsErroAuto
                MostraErro()
              EndIf
			        */
              RecLock("SA1",.F.)
              For nY := 3 To Len(aRegistro)
                &('SB1->'+aRegistro[nY,1]) := aRegistro[nY,2]
              Next 
              SA1->(MSUnlock())
            EndIF
          EndIf 
        
        Case cTabela == "SA2"
        
          nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "A2_COD"})
          nPosField2 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "A2_LOJA"})
        
          If nPosField1 > 0 .And. nPosField2 > 0
            If SA2->(MSseek(FWxFilial("SA2")+aRegistro[nPosField1,2]+aRegistro[nPosField2,2]))
              
              lMsErroAuto := .F.
              oModel := FwLoadModel("MATA020")
              FWMVCRotAuto( oModel,"SA2",MODEL_OPERATION_UPDATE,{{"SA2MASTER", aRegistro}})
              
              If lMsErroAuto
                MostraErro()
              EndIf 
          
            EndIf
          EndIf

          Case cTabela == "SB5"
          nPosField1 := aScan(aRegistro, {|x| AllTrim(Upper(x[1])) == "B5_COD"})
        
          If nPosField1 > 0
            If SB5->(MSseek(FWxFilial("SB5")+aRegistro[nPosField1,2]))
              
              lMsErroAuto := .F.
              oModel := FwLoadModel("MATA180")
              FWMVCRotAuto( oModel,"SB5",MODEL_OPERATION_UPDATE,{{"SB5MASTER", aRegistro}})
        
              If lMsErroAuto
              MostraErro()
              EndIf
        
            EndIF 
          EndIf 
        
      EndCase
    EndIf     
  Endif
FT_FSKIP()
EndDo

FT_FUSE()

Return
