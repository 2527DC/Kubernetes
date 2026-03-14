🚨 **Kubernetes Scenario Question (DevOps / Platform Engineers)**

I faced an interesting situation while testing a rollout in Kubernetes.

Here’s the scenario 👇

I had a Deployment exposing an application through a Service.

To access it locally I ran:

`kubectl port-forward svc/sample-data-service 8080:80 -n dev`

Initially everything worked perfectly.

Browser → `http://localhost:8080`
The application loaded successfully.

Then I updated the container image and performed a rollout:

`kubectl rollout restart deployment sample-data`

The rollout completed successfully and the new Pod was **Running**.

However, when I tried to access the application again from the browser, I started getting **timeouts** even though:

• The Pod was Running
• The Service was healthy
• The application was reachable internally inside the cluster

---

❓ **Question: Why did the browser start timing out after the rollout?**

**Options:**

A️⃣ The Service selector stopped matching the Pod labels after the rollout

B️⃣ The container was not listening on `0.0.0.0`, so the Service could not reach it

C️⃣ `kubectl port-forward` connects to a specific Pod behind the Service, and the connection breaks when that Pod is terminated during rollout

D️⃣ Kubernetes Services cannot route traffic during Deployment rollouts

---

✅ **Correct Answer: C**

**Explanation**

Even when we run:

`kubectl port-forward svc/sample-data-service 8080:80`

the port-forward command does **not continuously load balance through the Service**.

Instead, `kubectl` does the following:

1️⃣ It queries the Service endpoints
2️⃣ Selects **one Pod** behind the Service
3️⃣ Creates a **direct tunnel to that Pod**

So the actual flow becomes:

Local Browser
→ kubectl port-forward tunnel
→ Selected Pod

During a Deployment rollout:

Old Pod → Terminating
New Pod → Starting

If the Pod that `kubectl port-forward` is attached to gets terminated, the **tunnel breaks**, which results in:

• Timeout errors
• “lost connection to pod” messages
• port-forward stream failures

Even though the **Service is still correctly routing traffic internally**.

---

💡 **Key takeaway**

`kubectl port-forward` is mainly a **debugging tool**, not a production traffic path.

For stable external access during rollouts, use:

• Ingress
• LoadBalancer Service
• NodePort

---

Curious to know:
How do you usually access services during local Kubernetes debugging? 👇
