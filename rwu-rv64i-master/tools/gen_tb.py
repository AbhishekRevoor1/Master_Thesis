import os
from jinja2 import Template

template_file = "tools/templates/tb_template.sv"
output_dir = "tb_gen"
asm_dir = "rv64Sim"
asm_files = [f for f in os.listdir(asm_dir) if f.endswith(".asm")]

os.makedirs(output_dir, exist_ok=True)

with open(template_file) as tf:
    tmpl = Template(tf.read())

for asm in asm_files:
    name = asm.replace(".asm", "")
    tb_sv = tmpl.render(tb_name=f"tb_{name}", asm_name=name)
    with open(f"{output_dir}/tb_{name}.sv", "w") as out:
        out.write(tb_sv)

print(f"Generated {len(asm_files)} testbenches in tb_gen/")

