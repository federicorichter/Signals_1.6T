#--> Original PCS Lanes Matrix
pcsl_am = [
    0x9A4A26B665B5D9D9FE8E0C260171F3,
    0x9A4A260465B5D967A52181985ADE7E,
    0x9A4A264665B5D9FEC10CA9013EF356,
    0x9A4A265A65B5D984797F2F7B8680D0,
    0x9A4A26E165B5D919D5AE0DE62A51F2,
    0x9A4A26F265B5D94EEDB02EB1124FD1,
    0x9A4A263D65B5D9EEBD635E11429CA1,
    0x9A4A262265B5D9322989A4CDD6765B,
    0x9A4A266065B5D99F1E8C8A60E17375,
    0x9A4A266B65B5D9A28E3BC35D71C43C,
    0x9A4A26FA65B5D9046A1427FB95EBD8,
    0x9A4A266C65B5D971DD99C78E226638,
    0x9A4A261865B5D95B5D096AA4A2F695,
    0x9A4A261465B5D9CCCE683C333197C3,
    0x9A4A26D065B5D9B13504594ECAFBA6,
    0x9A4A26B465B5D956594586A9A6BA79
]

#--> Define new PCSL Reordered Matrix
pcsl_am_reorder = [
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0
]


for j in range(16):
    for i in range(15):
        aux = 0x0

        for k in range(8):
            aux  |= ((pcsl_am[j] >> (120 - 1 - k - i*8)) & 0b1) << k

        pcsl_am_reorder[j] |= aux << (120 - (8*(i+1)))

    print(f"pcsl_am_reorder[{j}] = ",bin(pcsl_am_reorder[j]))



#--> Start AM Distribution into four codewords
codeword_a = 0x0
codeword_b = 0x0
codeword_c = 0x0
codeword_d = 0x0

for k in range(3):
    for j in range(16):
        codeword_a |= ((pcsl_am_reorder[j] >> 120 - 40*k - 10) & 0b1111111111) << (480 - 160*k - 10*j - 10)
        codeword_b |= ((pcsl_am_reorder[j] >> 120 - 40*k - 20) & 0b1111111111) << (480 - 160*k - 10*j - 10)
        codeword_c |= ((pcsl_am_reorder[j] >> 120 - 40*k - 30) & 0b1111111111) << (480 - 160*k - 10*j - 10)
        codeword_d |= ((pcsl_am_reorder[j] >> 120 - 40*k - 40) & 0b1111111111) << (480 - 160*k - 10*j - 10)

print('\n\n ------------------------- \n\n')
print("codeword_a = ",bin(codeword_a))
print("codeword_b = ",bin(codeword_b))
print("codeword_c = ",bin(codeword_c))
print("codeword_d = ",bin(codeword_d))



#--> From Codewords to PCS Lanes post FEC distribution
pcsl =  [
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0,
    0x0
]

print('\n\n ------------------------- \n\n')
for k in range(3):
    for j in range(16):
        pcsl[j] |= ((codeword_a >> 480 - 160*k - 10*j - 10) & 0b1111111111) << (120 - 40*k - 10)
        pcsl[j] |= ((codeword_b >> 480 - 160*k - 10*j - 10) & 0b1111111111) << (120 - 40*k - 20)
        pcsl[j] |= ((codeword_c >> 480 - 160*k - 10*j - 10) & 0b1111111111) << (120 - 40*k - 30)
        pcsl[j] |= ((codeword_d >> 480 - 160*k - 10*j - 10) & 0b1111111111) << (120 - 40*k - 40)

for j in range(16):
    print(f"pcsl[{j}] = ",bin(pcsl[j]))
    print(f"pcsl[{j}] = ",hex(pcsl[j]))