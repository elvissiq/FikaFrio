#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//--------------------------------------------------------------------------------
/*/{protheusDoc.marcadores_ocultos} PFAT0016

  @Parâmetro pItens - itens do pedido de venda

  @Autor Elvis Siqueira (TOTVS)
  @sample
    Função para enviar Pedido de Venda ao FUSION.

  Retorno
  @história
  09/01/2025 - Desenvolvimento da Rotina.
/*/
//-------------------------------------------------------------------------------- 
User Function PFAT0016(pItens)
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local cStatus := ""
  Local cFCarga := ""
  Local cQuery  := ""
  Local cPedido := ""
  Local lCarga  := .T.
  Local lLerSC6 := .F.
	Local cNota   := ""
	Local cSerie  := ""
	Local cCarga  := ""
	Local cSeqCar := ""
  Local QFUS    := GetNextAlias()

  Default pItens := {}

  If Len(pItens) > 0
    cPedido := pItens[01]
  else 
    cPedido := SC5->C5_NUM
    lCarga  := IIf(SC5->C5_TPCARGA == "1",.T.,.F.)
  EndIf    

  If lCarga
    cQuery := "Select SC9.C9_XSEQFUS from " + RetSqlName("SC9") + " SC9"
    cQuery += "  where SC9.D_E_L_E_T_ <> '*'"
    cQuery += "    and SC9.C9_FILIAL  = '" + xFilial("SC9") + "'"
    cQuery += "    and SC9.C9_PEDIDO  = '" + cPedido + "'"
    cQuery := ChangeQuery(cQuery)
    dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),QFUS,.F.,.T.) 
    lLerSC6 := (QFUS)->(Eof())
    (QFUS)->(dbCloseArea())

    // --- Parametro: 1 - Pedido Venda
    //                2 - Sequencial do Pedido
    //                3 - Testar bloqueio do Pedido
    //                4 - Registro deletado
    // ---------------------------------------------
    aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,0,.F.,cNota,cSerie,cCarga,cSeqCar)
    
    If aRet[01]
      oFusion:aRegistro := IIf(Len(aRet[04]) > 0,aRet[04],aRet[03]) // Registro do Pedido de Venda
      If Len(aRet[04]) > 0
        cStatus := "1"

        cQuery := "Select SC9.C9_CARGA from " + RetSqlName("SC9") + " SC9"
        cQuery += "  where SC9.D_E_L_E_T_ <> '*'"
        cQuery += "    and SC9.C9_FILIAL  = '" + xFilial("SC9") + "'"
        cQuery += "    and SC9.C9_PEDIDO  = '" + cPedido + "'"
        cQuery := ChangeQuery(cQuery)
        dbUseArea(.T.,"TOPCONN",TCGenQry(,,cQuery),QFUS,.F.,.T.) 
        While (QFUS)->(!Eof())
            If !Empty((QFUS)->C9_CARGA)
              cFCarga := "N"
              lCarga  := .T.
              Exit
            EndIf
            (QFUS)->(DBSkip())
        EndDo
        (QFUS)->(dbCloseArea())
        If Empty(cFCarga)
          cFCarga := "S"
          lCarga  := .F.
        EndIF 
      else  
        cStatus := "B"
        cFCarga := "N"
        lCarga  := .F.
      EndIf
      // -- Parâmetro: cStatus - '1' = Normal
      //                         'B' = Bloqueado
      //                         'C' = Cancelado
      //               cFCarga - 'S' = Sim forma carga
      //                         'N' = Não forma carga 
      //               lCarga  - .T. = Número da carga
      //                         .F. = Sem número da carga  
      // -------------------------------------------------
      oFusion:saveEntregaServico(cStatus,cFCarga,lCarga)
        
      aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION
      If !aRet[01]
        ApMsgAlert("Erro ao enviar o Pedido: " + cPedido + " -----> " + aRet[02],"ATENÇÃO - Integração Fusion")
      Else
        Reclock("SC5",.F.)
          Replace SC5->C5_XSTATUS with "S"
        SC5->(MsUnlock())
      EndIf
    else
      ApMsgAlert(aRet[02])  
    EndIf   
  EndIf

Return
