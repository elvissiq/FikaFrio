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
User Function A410EXC()
  Local lRet := .T.

  If SC5->C5_TPCARGA == "1" .and. SC5->C5_XSTATUS == "S" 
  EndIf
Return lRet
