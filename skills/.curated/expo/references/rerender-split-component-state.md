---
title: Split Components to Isolate Frequently Updating State
impact: MEDIUM
impactDescription: reduces re-render scope from N components to 1-3
tags: rerender, state, component-splitting, isolation
---

## Split Components to Isolate Frequently Updating State

Extract frequently updating state into small, dedicated components. This prevents re-rendering the entire parent tree when only a small piece of UI needs to update.

**Incorrect (entire form re-renders on each keystroke):**

```typescript
function CheckoutForm() {
  const [cardNumber, setCardNumber] = useState('')
  const [expiry, setExpiry] = useState('')
  const [cvv, setCvv] = useState('')
  const [billingAddress, setBillingAddress] = useState({})
  const [items, setItems] = useState(initialItems)

  return (
    <View>
      <OrderSummary items={items} />  {/* Re-renders on every keystroke */}
      <ShippingOptions />  {/* Re-renders on every keystroke */}

      <TextInput
        value={cardNumber}
        onChangeText={setCardNumber}
        placeholder="Card Number"
      />
      <TextInput
        value={expiry}
        onChangeText={setExpiry}
        placeholder="MM/YY"
      />
      <TextInput
        value={cvv}
        onChangeText={setCvv}
        placeholder="CVV"
      />

      <BillingAddressForm
        address={billingAddress}
        onChange={setBillingAddress}
      />  {/* Re-renders on every keystroke */}
    </View>
  )
}
```

**Correct (isolated state in focused components):**

```typescript
function CheckoutForm() {
  const [items] = useState(initialItems)

  return (
    <View>
      <OrderSummary items={items} />
      <ShippingOptions />
      <PaymentFields />  {/* Card inputs isolated here */}
      <BillingAddressSection />  {/* Address inputs isolated here */}
      <SubmitButton />
    </View>
  )
}

// Isolated component with its own state
function PaymentFields() {
  const [cardNumber, setCardNumber] = useState('')
  const [expiry, setExpiry] = useState('')
  const [cvv, setCvv] = useState('')

  return (
    <View>
      <TextInput
        value={cardNumber}
        onChangeText={setCardNumber}
        placeholder="Card Number"
      />
      <TextInput
        value={expiry}
        onChangeText={setExpiry}
        placeholder="MM/YY"
      />
      <TextInput
        value={cvv}
        onChangeText={setCvv}
        placeholder="CVV"
      />
    </View>
  )
}

function BillingAddressSection() {
  const [address, setAddress] = useState({})
  // Only this section re-renders when address changes
  return <BillingAddressForm address={address} onChange={setAddress} />
}
```

**Common state isolation patterns:**
- Search input with results list
- Timer/counter displays
- Form sections with validation
- Real-time updating values (prices, counts)

**Lift state up only when necessary:**
When components need to share state, lift it to the nearest common ancestor, not to the root.
