#Include "Protheus.ch"
#Include "TOPCONN.ch"
#Include "TOTVS.ch"

//------------------------------------------------
/*/ Rotina FFFATM01

   Fun��o para enviar Pedido de Venda ao FUSION.

  @Autor Anderson Almeida - TOTVS
  @since  28/08/2024 - Desenvolvimento da Rotina.
/*/
//------------------------------------------------- 
User Function FFFATM01()
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}
  Local cStatus := ""
  Local cFCarga := ""
  Local cSeqFus := ""

  If SC5->C5_TPCARGA == "1"
    // --- Parametro: 1 - Pedido Venda
    //                2 - Sequencial do Pedido
    //                3 - Testar bloqueio do Pedido
    //                4 - Nota Fiscal de sa�da
    //                5 - Serie da NF de sa�da
    // ---------------------------------------------
     If ! oFusion:ValidaCad(SC5->C5_NUM)            // Validar Cadastro de Produto Complementos
        ApMsgAlert("Existe produto(s) sem cadastro complementar. " + CRLF +;
                   "Verifique o cadastro 'Complemento de Produto'.","ATEN��O")
        Return
     EndIf 
     
     aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,Val(cSeqFus),.F.,"","")

     If aRet[01]
        oFusion:aRegistro := IIf(Len(aRet[04]) > 0,aRet[04],aRet[03])                    // Registro do Pedido de Venda

        If Len(aRet[04]) > 0
           cStatus := "1"
           cFCarga := "S" 
         else  
           cStatus := "B"
           cFCarga := "N"
        EndIf

       // -- Par�metro: cStatus - '1' = Normal
       //                         'B' = Bloqueado
       //                         'C' = Cancelado
       //               cFCarga - 'S' = Sim forma carga
       //                         'N' = N�o forma carga 
       //               lCarga  - .T. = N�mero da carga
       //                         .F. = Sem n�mero da carga  
       // -------------------------------------------------
        oFusion:saveEntregaServico(cStatus,cFCarga,.F.)
           
        aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION

        If aRet[01]
           ApMsgInfo("Pedido enviado para FUSION com sucesso.")
         else
           ApMsgAlert(aRet[02],"ATEN��O")  
        EndIf
      else
        ApMsgAlert(aRet[02])  
     EndIf   
  EndIf   
Return