v = [("Alice","227 CSL"),("Bob","1210 Siebel Center"),
     ("Charlie", "2120 ECE Building")]
v.sort(key=lambda x: x[1])
print(v)