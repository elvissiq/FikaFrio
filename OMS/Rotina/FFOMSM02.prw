#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "PROTHEUS.CH"
#Include "PARMTYPE.CH"
#Include "TbiConn.ch"
#Include "TbiCode.ch"
#Include "APWebSrv.ch"

// ------------------------------------------------------
/*/ Rotina FFOMSM01

   Schedule para consumir a API do FUSION e verficar 
   se a carga serar montada ou atualizar o status
   no PROTHEUS. 
 
  @par�metro pParam[1] = "S" - Execu��o Via Schedule
                         "M" - Execu��o Via Menu
  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//--------------------------------------------------------
User Function FFOMSM02(pParam, pEmpresa, pFilial)
  Local cEmpPro := pEmpresa				            	// Empresa para processamento
  Local cFilPro := pFilial				            	// Filial para processamento

  Default pParam := {"M"}

  Private cTpExec        := pParam[01]
  Private lMsHelpAuto    := .T.   // Variavel de controle interno do ExecAuto
  Private lMsErroAuto    := .F.   // Variavel que informa a ocorr�ncia de erros no ExecAuto
  Private lAutoErrNoFile := .T.   // Variavel que gravar o erro log em arquivo

  If pParam[01] == "S"                          // Execu��o via Schedule
     Conout("COMECOU O PROCESSAMENTO - POMSS001 *****")
  
     Sleep(5000)                                // Aguarda para evitar erro de __CInternet 

     lPrepEnv := ! Empty(cEmpPro) .and. ! Empty(cFilPro)

     If lPrepEnv
	      RPCSetType(3)
        RpcSetEnv(cEmpPro,cFilPro,Nil,Nil,"OMS")

      elseIf Empty(cEmpAnt) .and. Empty(cFilAnt) 
	           Conout("N�o foram informados os parametros do processo no arquivo INI")
	           Return	
     EndIf
     
     fnF01Pro()
   else                                          // Execu��o via Menu
     MsAguarde({|| fnF01Pro()},"Processando integra��o...")
  EndIf
Return  
  
// -------------------------------------------------------
/*/ Fun��o fnF01Pro

   Processamento verifica��o das carga no FUSION.

  @since 02/10/2024 - Desenvolvimento da Rotina.
/*/
// --------------------------------------------------------
Static Function fnF01Pro()
  Local nId  := 0
  Local aRet := {}

  Private oFusion   := PCLSFUSION():New()
  Private aErro     := {}
  Private cMsgExc   := ""
  Private cCmdMsg   := IIf(cTpExec == "S","Conout","ApMsgInfo")
  Private lProcesOK := .T.

  oFusion:getIntErp()                                // Montar requisi��o de envio

  aRet := oFusion:Enviar("getIntErp")                // Enviar para FUSION 

  If ! aRet[01]
     cMsgExc := cCmdMsg + "('" + aRet[02] + "')"
     &cMsgExc
	    
	   Return
  EndIf    

  If ValType(oFusion:oParseJSON) <> "A"
     cMsgExc := cCmdMsg + "('N�o existe Carga h� ser processado.')"
     &cMsgExc

     Return
   elseIf Len(oFusion:oParseJSON) == 0
          cMsgExc := cCmdMsg + "('N�o existe Carga h� ser processado.')"
          &cMsgExc

          Return
  EndIf

  dbSelectArea("DAK")
  DAK->(dbOrderNickName("FUSION"))

  For nId := 1 To Len(oFusion:oParseJSON)
      If DAK->(dbSeek(FWxFilial("DAK") + oFusion:oParseJSON[nId]["t10_id"]))
         fnF01Aut()
       else
         fnF01Grv(Nil,Nil,nId)
      EndIf
  Next

  If lProcesOK
//     cMsgExc := cCmdMsg + "('Processamento realizado com sucesso.')"
     ApMsgInfo("Processamento realizado com sucesso.","INFORMA��O")
   else
     If Len(aErro) > 0 
        For nId := 1 To Len(aErro)
            cMsgExc += aErro[nId] + " "
        Next
     EndIf

//     cMsgExc := "ApMsgAlert('" + AllTrim(cMsgExc) + "','ATEN��O')"
     ApMsgAlert(AllTrim(cMsgExc),"ATEN��O")
  EndIf

//  &cMsgExc  
Return

//-------------------------------------------------------------------
/*/ Fun��o fnF01Aut
  
    Alterar informa��o da Carga

  @author Anderson Almeida - TOTVS
  @since 28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fnF01Aut()
Return

//-------------------------------------------------------------------
/*/ Fun��o fnF01Grv
  
    Montar Carga

  @author Anderson Almeida (TOTVS NE)
  @since   28/08/2024	
/*/
//-------------------------------------------------------------------
Static Function fnF01Grv(pEmpresa, pFilial, nId)
  Local lGerar    := .T.
  Local nPos      := 0
  Local aCab      := {}           // Array do cabe�alho da Carga
  Local aItem     := {}           // Array dos Pedidos da Carga
  Local aAutoErro := {}           // Array com os erros ExecAuto 
  Local aSequen   := {}           // Array com o Sequencia
  Local cPedido   := ""
  Local cDtSaida  := ""
  Local cQuery    := ""
  Local cAjudante := ""
  Local aAjudante := {"","","",""}

  cDtSaida := StrTran(Substr(oFusion:oParseJSON[nId]["t10_data_grava"],1,10),"-","")

  For nPos := 1 To 4
      aAjudante[nPos] := Substr(cAjudante,1,(At(",",cAjudante) - 1))
      cAjudante       := Substr(cAjudante,(At(",",cAjudante) + 1),Len(cAjudante))
  Next

  lMsErroAuto := .F.

  aAdd(aCab, {"DAK_FILIAL", FWxFilial("DAK")                                      , Nil})
  aAdd(aCab, {"DAK_COD"   , GetSX8Num("DAK","DAK_COD"), Nil})
  aAdd(aCab, {"DAK_SEQCAR", "01"                                                  , Nil})
  aAdd(aCab, {"DAK_ROTEIR", "999999"                                              , Nil})
  aAdd(aCab, {"DAK_CAMINH", oFusion:oParseJSON[nId]["t06_codigo_erp"]             , Nil})
  aAdd(aCab, {"DAK_MOTORI", oFusion:oParseJSON[nId]["t05_codigo_erp"]             , Nil})
  aAdd(aCab, {"DAK_PESO"  , Val(oFusion:oParseJSON[nId]["peso"])                  , Nil})
  aAdd(aCab, {"DAK_DATA"  , SToD(cDtSaida)                                        , Nil})
  aAdd(aCab, {"DAK_HORA"  , Substr(oFusion:oParseJSON[nId]["t10_data_grava"],12,8), Nil})
  aAdd(aCab, {"DAK_JUNTOU", "MANUAL"                                              , Nil})
  aAdd(aCab, {"DAK_ACECAR", "2"                                                   , Nil})
  aAdd(aCab, {"DAK_ACEVAS", "2"                                                   , Nil})
  aAdd(aCab, {"DAK_ACEFIN", "2"                                                   , Nil})
  aAdd(aCab, {"DAK_FLGUNI", "2"                                                   , Nil})
  aAdd(acab, {"DAK_TRANSP", "999999"                                              , Nil})
  aAdd(aCab, {"DAK_AJUDA1", aAjudante[01]                                         , Nil})
  aAdd(aCab, {"DAK_AJUDA2", aAjudante[02]                                         , Nil})
  aAdd(aCab, {"DAK_AJUDA3", aAjudante[03]                                         , Nil})
  aAdd(aCab, {"DAK_OK"    , "0006"                                                , Nil})
  aAdd(aCab, {"DAK_HRSTAR", Substr(oFusion:oParseJSON[nId]["t10_data_grava"],12,8), Nil})
  aAdd(aCab, {"DAK_CDTPOP", "1"                                                   , Nil})

  dbSelectArea("SC5")
  SC5->(dbSetOrder(1))

  dbSelectArea("SA1")
  SA1->(dbSetOrder(1))

  For nPos := 1 To Len(oFusion:oParseJSON[nId]["ENTREGAS"])
      cPedido := Substr(oFusion:oParseJSON[nId]["ENTREGAS"][nPos]["t32_pedido_original"],1,TamSX3("C5_NUM")[1])

      lGerar := SC5->(dbSeek(FWxFilial("SC5") + cPedido))

      If ! lGerar
         aAdd(aErro, "ERRO Carga: " + oFusion:oParseJSON[nId]["t10_id"] + " - Pedido: " + cPedido + " n�o encontrado")

         lMsErroAuto := .T.
         lProcesOK   := .F.
         
         Exit
      EndIf

     // -- Limpar transportadora do PV
     // ------------------------------
      Reclock("SC5",.F.)
        Replace SC5->C5_TRANSP with ""
      SC5->(MsUnlock())
     // ------------------------------  

      SA1->(DbSeek(FWxFilial("SA1") + SC5->C5_CLIENTE + SC5->C5_LOJACLI))

      aAdd(aItem, {oFusion:oParseJSON[nId]["t10_id"],;                        // 01 - C�digo da carga
                   "999999",;                                                 // 02 - C�digo da Rota - 999999 (Gen�rica)
                   "999999",;                                                 // 03 - C�digo da Zona - 999999 (Gen�rica)
                   "999999",;                                                 // 04 - C�digo do Setor - 999999 (Gen�rico)
                   SC5->C5_NUM,;                                              // 05 - C�digo do Pedido Venda
                   SA1->A1_COD,;                                              // 06 - C�digo do Cliente
                   SA1->A1_LOJA,;                                             // 07 - Loja do Cliente
                   SA1->A1_NOME,;                                             // 08 - Nome do Cliente
                   SA1->A1_BAIRRO,;                                           // 09 - Bairro do Cliente
                   SA1->A1_MUN,;                                              // 10 - Munic�pio do Cliente
                   SA1->A1_EST,;                                              // 11 - Estado do Cliente
                   SC5->C5_FILIAL,;                                           // 12 - Filial do Pedido Venda
                   SA1->A1_FILIAL,;                                           // 13 - Filial do Cliente
                   Val(oFusion:oParseJSON[nId]["t06_peso_max_entregas"]),;    // 14 - Peso Total dos Itens
                   Val(oFusion:oParseJSON[nId]["t06_volume_max_entregas"]),;  // 15 - Volume Total dos Itens
                   "08:00",;                                                  // 16 - Hora Chegada
                   "0001:00",;                                                // 17 - Time Service
                   Nil,;                                                      // 18 - N�o Usado
                   SToD(""),;                                                 // 19 - Data Chegada
                   SToD(cDtSaida),;                                           // 20 - Data Sa�da
                   Nil,;                                                      // 21 - N�o Usado
                   Nil,;                                                      // 22 - N�o Usado
                   0,;                                                        // 23 - Valor do Frete
                   0,;                                                        // 24 - Frete Autonomo
                   0,;                                                        // 25 - Valor Total Itens (Calculado pelo OMSA200)
                   0,;                                                        // 26 - Quantidade Total Itens (Calculado pelo OMSA200)
                   Nil,;                                                      // 27 - N�o usado
                   ""})                                                       // 28 - Transportadora redespachante (n�o obrigat�rio)

      aAdd(aSequen, {oFusion:oParseJSON[nId]["t10_id"],;                              // 01 - C�digo da carga
                     SC5->C5_NUM,;                                                    // 02 - C�digo do Pedido Venda
                     oFusion:oParseJSON[nId]["ENTREGAS"][nPos]["t12_ordemEntrega"]})  // 03 - Ordem entrega
  Next 
 
  If lGerar
     SetFunName("OMSA200")

     MSExecAuto({|x,y,z| OMSA200(x,y,z)}, aCab, aItem,3)

     If lMsErroAuto
        aAutoErro := GetAutoGrLog() 

        aAdd(aErro, "ERRO no Romaneio: " + oFusion:oParseJSON[nId]["t10_id"])
  
        For nPos := 1 To Len(aAutoErro)
            If ! Empty(aAutoErro[nPos])
               aAdd(aErro, aAutoErro[nPos])
            EndIf
        Next

        DisarmTransaction()

        lProcesOK := .F.
      else
       // --- Atualizar o Ajudante
       // ------------------------
        Reclock("DAK",.F.)
          Replace DAK->DAK_AJUDA1 with aAjudante[01]
          Replace DAK->DAK_AJUDA2 with aAjudante[02]
          Replace DAK->DAK_AJUDA3 with aAjudante[03]
          Replace DAK->DAK_XIDFUS with AllTrim(oFusion:oParseJSON[nId]["t10_id"])
        DAK->(MsUnlock())
        
       // --- Atualizar o sequencial da Carga
       // -----------------------------------
        dbSelectArea("DAI")
        DAI->(dbSetOrder(4)) 

        dbSelectArea("SC9")
        SC9->(dbSetOrder(5))       

        For nPos := 1 To Len(aSequen)
            If DAI->(dbSeek(FWxFilial("DAI") + aSequen[nPos][02] + aSequen[nPos][01] + "01"))
               cQuery := "Update " + RetSqlName("SC9")
               cQuery += "  Set C9_SEQENT = '" + StrZero(Val(aSequen[nPos][03]),TamSX3("C9_SEQENT")[1]) + "'"
               cQuery += "   where D_E_L_E_T_ <> '*'"
               cQuery += "     and C9_FILIAL  = '" + FWxFilial("SC9") + "'"
               cQuery += "     and C9_CARGA   = '" + DAI->DAI_COD + "'"
               cQuery += "     and C9_SEQCAR  = '" + DAI->DAI_SEQCAR + "'"
               cQuery += "     and C9_SEQENT  = '" + DAI->DAI_SEQUEN + "'"
	
               TCSQLEXEC(cQuery)

               Reclock("DAI",.F.)
                 Replace DAI->DAI_SEQUEN with StrZero(Val(aSequen[nPos][03]),TamSX3("DAI_SEQUEN")[1])
               DAI->(MsUnlock())
            EndIf            
        Next

        lProcesOK := IIf(lProcesOK,.T.,.F.)

        aAdd(aErro, "Sucesso na execu��o, Romaneio: " + oFusion:oParseJSON[nId]["t10_id"])
        
        oFusion:setIntErp(oFusion:oParseJSON[nId]["CODIGO_INT"], DAK->DAK_COD)

        aRet := oFusion:Enviar("setIntErp")                   // Enviar para FUSION 

        If ! aRet[01]
           cMsgExc := cCmdMsg + "('" + aRet[02] + "')"
           &cMsgExc

           lProcesOK := .F.
	    
	         Return
        EndIf    
     EndIf
  EndIf   
Return
