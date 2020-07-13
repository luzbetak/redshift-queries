SELECT *
FROM svv_table_info
WHERE "table" IN ('cst_service_concession',
                  'cst_product_params',
                  'cst_full_period_rentals',
                  'cst_exi_message',
                  'cst_cug_header',
                  'cst_sim_service');

