-- =============================================
-- Funciones de Stock para BeniceFlutter
-- Equivalente a las funciones de BeniceAstro
-- =============================================

-- Función para reducir stock de un producto
CREATE OR REPLACE FUNCTION reduce_product_stock(
    p_product_id UUID,
    p_quantity INTEGER
)
RETURNS VOID AS $$
BEGIN
    -- Verificar que el producto existe
    IF NOT EXISTS (SELECT 1 FROM public.products WHERE id = p_product_id) THEN
        RAISE EXCEPTION 'Producto no encontrado: %', p_product_id;
    END IF;
    
    -- Verificar stock suficiente
    IF NOT EXISTS (SELECT 1 FROM public.products WHERE id = p_product_id AND stock >= p_quantity) THEN
        RAISE EXCEPTION 'Stock insuficiente para el producto %', p_product_id;
    END IF;
    
    -- Reducir stock
    UPDATE public.products 
    SET stock = stock - p_quantity,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Log del cambio (opcional)
    INSERT INTO public.stock_logs (product_id, quantity_change, operation, created_at)
    VALUES (p_product_id, -p_quantity, 'reduce', NOW());
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Función para restaurar stock de un producto
CREATE OR REPLACE FUNCTION restore_product_stock(
    p_product_id UUID,
    p_quantity INTEGER
)
RETURNS VOID AS $$
BEGIN
    -- Verificar que el producto existe
    IF NOT EXISTS (SELECT 1 FROM public.products WHERE id = p_product_id) THEN
        RAISE EXCEPTION 'Producto no encontrado: %', p_product_id;
    END IF;
    
    -- Restaurar stock
    UPDATE public.products 
    SET stock = stock + p_quantity,
        updated_at = NOW()
    WHERE id = p_product_id;
    
    -- Log del cambio (opcional)
    INSERT INTO public.stock_logs (product_id, quantity_change, operation, created_at)
    VALUES (p_product_id, p_quantity, 'restore', NOW());
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Función para verificar stock múltiple (carrito)
CREATE OR REPLACE FUNCTION check_cart_stock_availability(
    p_items JSONB
)
RETURNS TABLE(
    product_id UUID,
    available BOOLEAN,
    current_stock INTEGER,
    requested_quantity INTEGER
) AS $$
DECLARE
    item RECORD;
BEGIN
    -- Para cada item en el carrito
    FOR item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        RETURN QUERY
        SELECT 
            (item->>'product_id')::UUID as product_id,
            CASE 
                WHEN p.stock >= (item->>'quantity')::INTEGER THEN true 
                ELSE false 
            END as available,
            p.stock as current_stock,
            (item->>'quantity')::INTEGER as requested_quantity
        FROM public.products p
        WHERE p.id = (item->>'product_id')::UUID;
    END LOOP;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Función optimizada para crear pedido y reducir stock atómicamente
-- Equivalente a create_order_and_reduce_stock de BeniceAstro
CREATE OR REPLACE FUNCTION create_order_and_reduce_stock_flutter(
    p_user_id UUID, 
    p_total NUMERIC, 
    p_items JSONB,
    p_promo_code TEXT DEFAULT NULL, 
    p_discount_amount NUMERIC DEFAULT 0,
    p_shipping_address TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
    new_order_id UUID;
    item RECORD;
BEGIN
    -- Verificar stock para todos los productos ANTES de crear el pedido
    FOR item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        IF NOT EXISTS (
            SELECT 1 FROM public.products 
            WHERE id = (item->>'product_id')::UUID 
            AND stock >= (item->>'quantity')::INTEGER
        ) THEN
            RAISE EXCEPTION 'Stock insuficiente para el producto %', item->>'product_id';
        END IF;
    END LOOP;
    
    -- Crear el pedido
    INSERT INTO public.orders (
        user_id, total, status, promo_code, discount_amount, shipping_address
    )
    VALUES (
        p_user_id, p_total, 'pagado', p_promo_code, p_discount_amount, p_shipping_address
    )
    RETURNING id INTO new_order_id;
    
    -- Insertar items y reducir stock atómicamente
    FOR item IN SELECT * FROM jsonb_array_elements(p_items) LOOP
        -- Insertar item del pedido
        INSERT INTO public.order_items (order_id, product_id, quantity, price)
        VALUES (
            new_order_id, 
            (item->>'product_id')::UUID, 
            (item->>'quantity')::INTEGER, 
            (item->>'price')::NUMERIC
        );
        
        -- Reducir stock
        UPDATE public.products 
        SET stock = stock - (item->>'quantity')::INTEGER,
            updated_at = NOW()
        WHERE id = (item->>'product_id')::UUID;
        
        -- Log del cambio
        INSERT INTO public.stock_logs (product_id, quantity_change, operation, order_id, created_at)
        VALUES (
            (item->>'product_id')::UUID, 
            -(item->>'quantity')::INTEGER, 
            'order_reduction', 
            new_order_id, 
            NOW()
        );
    END LOOP;
    
    RETURN new_order_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Función para cancelar pedido y restaurar stock
-- Equivalente a cancel_order_and_restore_stock de BeniceAstro
CREATE OR REPLACE FUNCTION cancel_order_and_restore_stock_flutter(
    p_order_id UUID
)
RETURNS VOID AS $$
DECLARE
    item RECORD;
    order_status TEXT;
BEGIN
    -- Verificar que el pedido existe y está en estado cancelable
    SELECT status INTO order_status 
    FROM public.orders 
    WHERE id = p_order_id;
    
    IF order_status IS NULL THEN
        RAISE EXCEPTION 'Pedido no encontrado';
    END IF;
    
    IF order_status = 'cancelado' THEN
        RAISE EXCEPTION 'El pedido ya está cancelado';
    END IF;
    
    IF order_status = 'entregado' THEN
        RAISE EXCEPTION 'El pedido entregado no puede ser cancelado';
    END IF;
    
    -- Restaurar stock para cada item
    FOR item IN SELECT product_id, quantity FROM public.order_items WHERE order_id = p_order_id LOOP
        UPDATE public.products 
        SET stock = stock + item.quantity,
            updated_at = NOW()
        WHERE id = item.product_id;
        
        -- Log del cambio
        INSERT INTO public.stock_logs (product_id, quantity_change, operation, order_id, created_at)
        VALUES (item.product_id, item.quantity, 'order_restoration', p_order_id, NOW());
    END LOOP;
    
    -- Actualizar estado del pedido
    UPDATE public.orders 
    SET status = 'cancelado', updated_at = NOW() 
    WHERE id = p_order_id;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER SET search_path = public;

-- Tabla opcional para logs de stock (crear si no existe)
CREATE TABLE IF NOT EXISTS public.stock_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    product_id UUID NOT NULL REFERENCES public.products(id),
    quantity_change INTEGER NOT NULL,
    operation TEXT NOT NULL CHECK (operation IN ('reduce', 'restore', 'order_reduction', 'order_restoration')),
    order_id UUID REFERENCES public.orders(id),
    created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Índices para la tabla de logs
CREATE INDEX IF NOT EXISTS idx_stock_logs_product_id ON public.stock_logs(product_id);
CREATE INDEX IF NOT EXISTS idx_stock_logs_created_at ON public.stock_logs(created_at);
CREATE INDEX IF NOT EXISTS idx_stock_logs_operation ON public.stock_logs(operation);

-- RLS para stock_logs (solo admins pueden ver)
ALTER TABLE public.stock_logs ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Solo admins pueden ver logs de stock"
  ON public.stock_logs FOR SELECT
  TO authenticated
  USING (
    EXISTS (
      SELECT 1 FROM public.users u
      WHERE u.id = auth.uid() AND u.role = 'admin'
    )
  );

CREATE POLICY "Service role puede insertar logs de stock"
  ON public.stock_logs FOR INSERT
  TO service_role
  WITH CHECK (true);
