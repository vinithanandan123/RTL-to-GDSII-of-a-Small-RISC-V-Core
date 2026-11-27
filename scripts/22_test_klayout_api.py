import pya

print("KLayout version:", pya.Application.instance().version())

c = pya.Circuit()

print("Circuit has each_net:", hasattr(c, "each_net"))
print("Circuit has net_count:", hasattr(c, "net_count"))

n1 = c.create_net("test_net_1")
n2 = c.create_net("test_net_2")

net_count = sum(1 for _ in c.each_net())

print("Created nets:", net_count)
print("API TEST PASSED")
