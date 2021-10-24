CREATE OR REPLACE FUNCTION funcao_impostos ( PCOD_CON_PAGAR_PAI NUMBER  ,
                                             PCOD_CON_PAGAR_FILHO NUMBER ) RETURN VARCHAR2 IS

CURSOR C_ROWNUMBER IS  SELECT ROWNUMBER
                      FROM (
                      SELECT I.COD_ITCON_PAGAR,
                             c.cod_con_pagar,
                             T.cod_con_pagar_filho,
                             VALOR_BRUTO_CONTA ,
                             Row_Number ()OVER (ORDER BY cod_con_pagar_filho) ROWNUMBER

                      FROM owner. c,
                           owner. d,
                           owner. t,
                           owner. i,
                           owner. f
                           
                      WHERE   c.cod_tipo_doc       =   d.cod_tipo_doc
                      AND     t.cod_con_pagar_pai  =   c.cod_con_pagar
                      AND     c.cod_con_pagar      =   i.cod_con_pagar
                      and     c.cod_fornecedor     =   f.cod_fornecedor (+)
                      AND     i.nro_parcela        = Decode(Nvl(t.cod_itcon_pagar,0),0,1,i.nro_parcela)
                      AND     i.cod_itcon_pagar    = Nvl(t.cod_itcon_pagar, i.cod_itcon_pagar)
                      AND     cod_con_pagar_PAI    = PCOD_CON_PAGAR_PAI
                      
                      ) WHERE cod_con_pagar_filho  = PCOD_CON_PAGAR_FILHO;

CURSOR C_VALOR IS
                  SELECT DISTINCT VALOR_BRUTO_CONTA
                  FROM v_fornecedor_imposto
                  WHERE  COD_CON_PAG = POCD_CON_PAG_PAI;

V_VALOR VARCHAR2(10);
V_ROWNUMBER NUMBER(3);


BEGIN

OPEN C_ROWNUMBER;
FETCH C_ROWNUMBER INTO V_ROWNUMBER;
CLOSE C_ROWNUMBER;

IF V_ROWNUMBER <> 1 THEN  RETURN  0 ;

END IF;

IF  V_ROWNUMBER = 1 THEN

OPEN C_VALOR;
FETCH C_VALOR INTO V_VALOR;
CLOSE C_VALOR;

RETURN V_VALOR;

END IF;

END;
/
