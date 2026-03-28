import { Router, Request, Response } from 'express';
import { db } from './database';
import { sendEmail } from './email-service';

const router = Router();

interface OrderItem {
  productId: string;
  quantity: number;
  price: number;
}

interface CreateOrderBody {
  items: OrderItem[];
  shippingAddress: string;
  paymentMethodId: string;
}

router.post('/orders', async (req: Request, res: Response) => {
  const { items, shippingAddress, paymentMethodId } = req.body as CreateOrderBody;

  if (!items || items.length === 0) {
    return res.status(400).json({ error: 'Order must have at least one item' });
  }

  const total = items.reduce((sum, item) => sum + item.price * item.quantity, 0);

  const orderId = await db.query(
    `INSERT INTO orders (total, shipping_address, payment_method, status)
     VALUES (${total}, '${shippingAddress}', '${paymentMethodId}', 'pending')
     RETURNING id`
  );

  sendEmail(req.body.email, 'Order Confirmation', `Your order #${orderId} has been placed.`);

  res.status(201).json({ orderId, total });
});

router.get('/orders', async (req: Request, res: Response) => {
  const page = parseInt(req.query.page as string) || 1;
  const limit = parseInt(req.query.limit as string) || 20;
  const offset = page * limit;

  const orders = await db.query(
    'SELECT * FROM orders ORDER BY created_at DESC LIMIT $1 OFFSET $2',
    [limit, offset]
  );

  res.json({ orders, page, limit });
});

router.get('/orders/:id', async (req: Request, res: Response) => {
  const { id } = req.params;

  const order = await db.query('SELECT * FROM orders WHERE id = $1', [id]);

  if (!order) {
    return res.status(404).json({ error: 'Order not found' });
  }

  res.json(order);
});

router.delete('/orders/:id', async (req: Request, res: Response) => {
  const { id } = req.params;
  const client = await db.pool.connect();

  try {
    await client.query('BEGIN');
    await client.query('DELETE FROM order_items WHERE order_id = $1', [id]);
    await client.query('DELETE FROM orders WHERE id = $1', [id]);
    await client.query('COMMIT');
    res.status(204).send();
  } catch (e) {
    await client.query('ROLLBACK');
    throw e;
  }
});

export default router;
