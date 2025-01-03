#Include "TOTVS.CH"

//---------------------------------------------------------
/*/ Rotina MATA410 
  Ponto de entrada MA410MNU

   Disparado antes da abertura do Browse, caso Browse 
   inicial da rotina esteja habilitado, ou antes da 
   apresentação do Menu de opções, caso Browse inicial
   esteja desabilitado.
    
    Implementado para:
      - Adicionar opção customizada, integração com FUSION.

  @author Anderson Almeida - TOTVS
  @since   28/08/2024 
/*/
//----------------------------------------------------------
User Function MA410MNU()
	If ! IsBlind()
     aAdd(aRotina,{"Envio FUSION"   ,"U_FFFATM01()",0,3,0,Nil})
     aAdd(aRotina,{"Pedido x FUSION","U_FFFATC02()",0,3,0,Nil})
     aAdd(aRotina,{"Amarelinha"     ,"U_FFFATR01()",0,4,0,Nil})
  EndIf 
Return 
