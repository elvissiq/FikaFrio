#Include "TOTVS.ch"

//----------------------------------------------------
/*/ Rotina MATA410
  Ponto de entrada M410STTS
    
   Este ponto de entrada est� em todas as rotinas de
   inclus�o, altera��o, exclus�o, c�pia e devolu��o
   de compras. Executado ap�s todas as altera��es no
   arquivo de pedido terem sido feitas.

   Implementado para:
      - Enviar Pedido de Venda para o FUSION.
   
  @param 
    nOper = 3 - Inclus�o
            4 - Altera��o
            5 - Exclus�o
            6 - C�pia
            7 - Devolu��o de Compras
  @author Anderson Almeida - TOTVS
  @since  27/08/2024 - Desenvolvimento da Rotina.
/*/
//----------------------------------------------------- 
User Function M410STTS()
  Local nOper   := PARAMIXB[1]
  Local oFusion := PCLSFUSION():New()
  Local aRet    := {}

  Private cBlRegra := SC5->C5_BLQ

  If nOper <> 7
     If SC5->C5_TPCARGA == "1"
        If nOper <> 5
           Reclock("SC5",.F.)
             Replace SC5->C5_XSEQFUS with ""
           SC5->(MsUnlock())
        EndIf

       // -- Parametro: 1 - Pedido Venda
       //               2 - Testar bloqueio do Pedido
       //               3 - Sequencial do Pedido
       //               4 - Registro deletado
       // --------------------------------------------
        If nOper == 5
           aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,0,.T.,.T.)
         else  
           aRet := oFusion:LerPedidoVenda(SC5->C5_NUM,0,.T.,.F.)
        EndIf   

        If aRet[01]
           oFusion:aRegistro := IIf(Len(aRet[03]) > 0,aRet[03],aRet[04])  // Registro do Pedido de Venda

          // -- Par�metro: 1 - Normal, B - Bloqueado ou 9 - Cancelar
          // --            S = Pode formar carga; .T. = N. Carga 
          // ------------------------------------------------------- 
           oFusion:saveEntregaServico(IIf(_nOper == 5,"9","B"),"N",.T.)
           
           aRet := oFusion:Enviar("saveEntregaServico")     // Enviar para FUSION

           If aRet[01]
              ApMsgInfo(aRet[02])
            else
              ApMsgAlert(aRet[02],"ATEN��O")
           EndIf
         else
           ApMsgAlert(aRet[02])  
        EndIf   
     EndIf   
  EndIf
Return
