#Include "TOTVS.CH"
#Include "FWMBrowse.ch"

//---------------------------------------------------------
/*/ Rotina MATA460B 
  Ponto de entrada OM460MNU

   Este Ponto de Entrada permite manipular as opções do menu 
   Ações Relacionadas, da rotina Documento de Saída Por Carga 
   (MATA460B), sendo tanto a inclusão como a exclusão de opções.
    
    Implementado para:
      - Adicionar opção customizada, integração com FUSION.

  @author Elvis Siqueira - TOTVS
  @since  08/01/2025 
/*/
//----------------------------------------------------------
User Function OM460MNU()

  ADD OPTION aRotina TITLE "Atualiza NF Fusion" ACTION "U_PFUSATUNF()" OPERATION 7 ACCESS 0

Return
