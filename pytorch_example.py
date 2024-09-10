import torch

INPUT_DIM = 10
OUTPUT_DIM = 5

x = torch.randn(INPUT_DIM)
y_expected = torch.randn(OUTPUT_DIM)

class MyLinear(torch.nn.Module):
    def __init__(self):
        super(MyLinear, self).__init__()
        self.linear = torch.nn.Linear(INPUT_DIM, OUTPUT_DIM)

    def forward(self, x):
        return self.linear(x)
    
class MyLinearWithActivation(torch.nn.Module):
    def __init__(self):
        super(MyLinearWithActivation, self).__init__()
        self.linear = MyLinear()
        self.activation = torch.nn.Tanh()

    def forward(self, x):
        return self.activation(self.linear(x))

linear_with_activation = MyLinearWithActivation()
loss_fn = torch.nn.MSELoss()

y = linear_with_activation(x)
loss = loss_fn(y, y_expected)
loss.backward()
