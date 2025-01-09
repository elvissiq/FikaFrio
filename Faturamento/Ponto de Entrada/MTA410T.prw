#Include "TOTVS.ch"

//--------------------------------------------------------
/*/ Rotina MATA440 
  Ponto de entrada M410T

    Este ponto é executado após o fechamento da transação
    de liberação do pedido de venda (Automática).
    
    Implementado para:
      - Enviar Pedido de Venda para o FUSION.

  @author Anderson Almeida - TOTVS
  @since   11/12/2024 
  @Historico 
    09/01/2025 - Comentado por Elvis Siqueira
/*/
//--------------------------------------------------------
User Function MTA410T()
  /*
  Local oFusion := PCLSFUSION():New()
  Local cRetPrx := ""
  Local nX      := 0
  Local nPrxSeq := 0
  Local aRet    := {}
  Local aRetEnv := {}

  If FunName() == "MATA440"
     If SC5->C5_TPCARGA == "1"
       // -- Parametro: 1 - Pedido Venda
       //               2 - Testar bloqueio do Pedido
       //               3 - Sequencial do Pedido
       //               4 - Número da NF de saída
       //               5 - Serie da NF de saída
       // --------------------------------------------
        cRetPrx := oFusion:pegarPrxSeq(SC5->C5_NUM, SC9->(Recno()))
        nPrxSeq := IIf(Empty(cRetPrx),0,Val(cRetPrx) + 1)

        If ! oFusion:ValidaCad(SC5->C5_NUM)            // Validar Cadastro de Produto Complementos
           ApMsgAlert("Existe produto(s) sem cadastro complementar. " + CRLF +;
                      "Verifique o cadastro 'Complemento de Produto'.","ATENÇÃO")
           Return
        EndIf              

        aRet := oFusion:lerPedidoVenda(SC5->C5_NUM, nPrxSeq,.F.,"","","","")

        If aRet[01]
           If Len(aRet[04]) > 0                                
              oFusion:aRegistro := aRet[04]                       // Registro do Pedido de Venda

              oFusion:saveEntregaServico("1","S",.F.)             // 1 - Normal, B - Bloqueado ou C - Cancelado e Forma Carga
           
              aRetEnv := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION

              If aRetEnv[01]
                 dbSelectArea("SC9")
                 SC9->(dbSetOrder(1))

                 For nX := 1 To Len(oFusion:aRegistro)
                     SC9->(dbGoto(oFusion:aRegistro[nX][24]))

                     RecLock("SC9",.F.)
                       Replace SC9->C9_XSEQFUS with PadL(AllTrim(Str(nPrxSeq)),TamSX3("C9_XSEQFUS")[1],"0")
                     SC9->(MsUnlock())
                 Next

                 ApMsgInfo("Pedido enviado para FUSION com sucesso.","MTA410T")
               else
                 ApMsgAlert(aRetEnv[02],"ATENÇÃO")  
              EndIf
           EndIf
         else
           ApMsgAlert(aRet[02],"ATENÇÃO")  
        EndIf   
     EndIf
  EndIf
  */
Return
