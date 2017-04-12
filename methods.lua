methods = {}

function body(body, vtable, static)
  local var = {}
  for _, v in ipairs(body) do
    --** VAR_DEF
    if string.match(v, ":") then
      local id, tipo = string.match(v, "%s*var%s+(%a+)%s*:%s*(%a+)")
      if tipo == "number" then
        io.write(string.format("  int %s;\n", id))
      else
        io.write(string.format("  struct %s *%s;\n", tipo, id))
        var[id] = tipo
      end
    --** <ID> = new <ID>
    elseif string.match(v, "new") then
      local id, call = string.match(v, "%s*(%a+)%s*=%s+new%s*(%a+)")
      io.write(string.format("  %s = new_%s();\n", id, call))
    --** this.<ID>
    elseif string.match(v, "this%.") then
      local id1, id2 = string.match(v, "%s*(%a+)%s*=%s*this%.(%a+)")
      io.write(string.format("  %s = this->%s;\n", id1, id2))
    --** <ID> = <CALL>
    elseif string.match(v, "%a+%s*=%s*%a+%.%a+%s*%(") then
      local id1, id2, id3 = string.match(v, "%s*(%a+)%s*=%s*(%a+)%.(%a+)")
      local p1 = string.match(v, "%s*%a+%s*=%s*%a+%.%a+%(%s*(%a+)")
      local p2 = string.match(v, "%s*%a+%s*=%s*%a+%.%a+%(%s*%a+%s*,%s*(%a+)")
      local p3 = string.match(v, "%s*%a+%s*=%s*%a+%.%a+%(%s*%a+%s*,%s*%a+%s*,%s*(%a+)%s*%)")
      if #vtable[var[id2]] > 0 then
        if p1 and p2 and p3 then
          io.write(string.format("  %s = %s->vtable->%s(%s, %s, %s, %s);\n",
          id1, id2, id3, id2, p1, p2, p3))
        elseif p1 and p2 then
          io.write(string.format("  %s = %s->vtable->%s(%s, %s, %s);\n",
          id1, id2, id3, id2, p1, p2))
        elseif p1 then
          io.write(string.format("  %s = %s->vtable->%s(%s, %s);\n",
          id1, id2, id3, id2, p1))
        else
          io.write(string.format("  %s = %s->vtable->%s(%s);\n",
          id1, id2, id3, id2))
        end
      else
        if p1 and p2 and p3 then
          io.write(string.format("  %s = %s_meth_%s(%s, %s, %s, %s);\n",
          id1, var[id2], id3, id2, p1, p2, p3))
        elseif p1 and p2 then
          io.write(string.format("  %s = %s_meth_%s(%s, %s, %s);\n",
          id1, var[id2], id3, id2, p1, p2))
        elseif p1 then
          io.write(string.format("  %s = %s_meth_%s(%s, %s);\n",
          id1, var[id2], id3, id2, p1))
        else
          io.write(string.format("  %s = %s_meth_%s(%s);\n",
          id1, var[id2], id3, id2))
        end
      end
    --** <ID> = <ID> + <ID>
    elseif string.match(v, "+") then
      local id1, id2, id3 = string.match(v, "%s*(%a+)%s*=%s*(%a+)%s*%+%s*(%a+)")
      io.write(string.format("  %s = %s + %s;\n", id1, id2, id3))
    --** <ID> = <ID> - <ID>
    elseif string.match(v, "-") then
      local id1, id2, id3 = string.match(v, "%s*(%a+)%s*=%s*(%a+)%s*%-%s*(%a+)")
      io.write(string.format("  %s = %s - %s;\n", id1, id2, id3))
    --** <ID> = <NUMERO>
    elseif string.match(v, "%a+%s*=%s*%d+") then
      local id, number = string.match(v, "%s*(%a+)%s*=%s*(%d+)")
      io.write(string.format("  %s = %d;\n", id, number))
    --** <ID>.<ID> = <ID>
    elseif string.match(v, "%a+%.%a+%s*=") then
      local id1, id2, id3 = string.match(v, "%s*(%a+)%.(%a+)%s*=%s*(%a+)")
      io.write(string.format("  %s->%s = %s;\n", id1, id2, id3))
    --** <ID> = <ID>.<ID>
    elseif string.match(v, "%a+%s*=%s*(%a+)%.") then
      local id1, id2, id3 = string.match(v, "%s*(%a+)%s*=%s*(%a+)%.(%a+)")
      io.write(string.format("  %s = %s->%s;\n", id1, id2, id3))
    --** io.print
    elseif string.match(v, "io.print") then
      local id = string.match(v, "%s*io%.print%(%s*(%a+)%s*%)")
      if id then io.write(string.format("  printf(\"%%d\\n\", %s);\n", id))
      else io.write(string.format("  printf(\"\\n\");\n")) end
    --** <ID> = <ID>
    elseif string.match(v, "%a+%s*=") then
      local id1, id2 = string.match(v, "%s*(%a+)%s*=%s*(%a+)")
      if var[id1] then
        io.write(string.format("  %s = (struct %s*) %s;", id1, var[id1], id2))
      else
        io.write(string.format("  %s = %s;\n", id1, id2))
      end
    --** <CALL>
    elseif string.match(v, "%a+%.%a+") then
      local id1, id2 = string.match(v, "%s*(%a+)%.(%a+)")
      local p1 = string.match(v, "%s*%a+%.%a+%(%s*(%a+)")
      local p2 = string.match(v, "%s*%a+%.%a+%(%s*%a+%s*,%s*(%a+)")
      local p3 = string.match(v, "%s*%a+%.%a+%(%s*%a+%s*,%s*%a+%s*,%s*(%a+)")
      for _, meth in ipairs(vtable[var[id1]]) do
        if meth.name == id2 then
          found = true
          if p1 and p2 and p3 then
            io.write(string.format("  %s->vtable->%s(%s, %s, %s, %s);\n",
            id1, id2, id1, p1, p2, p3))
          elseif p1 and p2 then
            io.write(string.format("  %s->vtable->%s(%s, %s, %s);\n",
            id1, id2, id1, p1, p2))
          elseif p1 then
            io.write(string.format("  %s->vtable->%s(%s, %s);\n",
            id1, id2, id1, p1))
          else
            io.write(string.format("  %s->vtable->%s(%s);\n",
            id1, id2, id1))
          end
          break
        end
      end
      if not found then
        for _, meth in ipairs(static[var[id1]]) do
          if p1 and p2 and p3 then
            io.write(string.format("  %s_meth_%s(%s, %s, %s, %s);\n",
            var[id1], id2, id1, p1, p2, p3))
          elseif p1 and p2 then
            io.write(string.format("  %s_meth_%s(%s, %s, %s);\n",
            var[id1], id2, id1, p1, p2))
          elseif p1 then
            io.write(string.format("  %s_meth_%s(%s, %s);\n",
            var[id1], id2, id1, p1))
          else
            io.write(string.format("  %s_meth_%s(%s);\n",
            var[id1], id2, id1))
          end
        end
      end
    elseif string.match(v, "%s*return%s*") then
      local id = string.match(v, "%s*return%s*(%a+)")
      io.write(string.format("  return %s;\n", id))
    else
      io.write(v)
    end
  end
end

function methods.prototype(program, vtable, static)
  for _, class in ipairs(program.classes) do
    io.write(string.format("struct %s* new_%s(void);\n", class.name, class.name))
    for _, meth in ipairs(vtable[class.name]) do
      io.write(string.format("int %s_meth_%s(struct %s*", class.name,
      meth.name, class.name))
      methods.parameters(class, meth)
    end
    for _, meth in ipairs(static[class.name]) do
      io.write(string.format("int %s_meth_%s(struct %s*", class.name,
      meth.name, class.name))
      methods.parameters(class, meth)
    end
  end
end

function methods.constructor(program, vtable)
  for _, class in ipairs(program.classes) do
    io.write(string.format("\nstruct %s* new_%s(void) {\n", class.name, class.name))
    io.write(string.format("  struct %s *obj = malloc(sizeof *obj);\n", class.name))
    for _, attr in ipairs(class.attributes) do
      io.write(string.format("  obj->%s = 0;\n", attr.name))
    end
    for _, meth in ipairs(vtable[class.name]) do
      io.write(string.format("  obj->vtable = &vtable_%s;\n", class.name))
      io.write(string.format("  obj->vtable->%s = %s_meth_%s;\n", meth.name,
      class.name, meth.name))
    end
    io.write("  return obj;\n}\n")
  end
end

function methods.definition(program, vtable, static)
  for _, class in ipairs(program.classes) do
    for _, meth in ipairs(vtable[class.name]) do
      print_definition(class, meth, vtable, static)
    end
    for _, meth in ipairs(static[class.name]) do
      print_definition(class, meth, vtable, static)
    end
  end
end

function print_definition(class, meth, vtable, static)
  io.write(string.format("\nint %s_meth_%s(struct %s *this",
  class.name, meth.name, class.name))
  if #meth.params == 0 then
    io.write(") {")
  elseif #meth.params == 1 then
    if meth.params[1].tipo == "number" then
      io.write(string.format(", int %s) {", meth.params[1].name))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s *this) {"))
          break
        end
      end
    end
  elseif #meth.params == 2 then
    if meth.params[1].tipo == "number" then
      io.write(string.format(", int %s", meth.params[1].name))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s %s", paramclass.name,
          meth.params[1].name))
          break
        end
      end
    end
    if meth.params[2].tipo == "number" then
      io.write(string.format(", int %s) {", meth.params[2].name))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[2].tipo then
          io.write(string.format(", struct %s *%s) {",
          paramclass.name, meth.params[2].name))
          break
        end
      end
    end
  else
    if meth.params[1].tipo == "number" then
      io.write(string.format(", int %s", meth.params[1].name))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s *%s", paramclass.name,
          meth.params[1].name))
          break
        end
      end
    end
    if meth.params[2].tipo == "number" then
      io.write(string.format(", int %s", meth.params[2].name))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[2].tipo then
          io.write(string.format(", struct %s *%s", paramclass.name,
          meth.params[2].name))
          break
        end
      end
    end
    if meth.params[3].tipo == "number" then
      io.write(", int %s) {", meth.params[3].name)
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[3].tipo then
          io.write(string.format(", struct %s *%s) {", paramclass.name,
            meth.params[3].name))
          break
        end
      end
    end
  end
  io.write("\n")
  body(meth.body, vtable, static)
  io.write("}\n")
end -- ipair(class.methods)

function methods.parameters(class, meth)
  if #meth.params == 1 then
    if meth.params[1].tipo == "number" then
      io.write(string.format(", int"))
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s*"))
          break
        end
      end
    end
  elseif #meth.params == 2 then
    if meth.params[1].tipo == "number" then
      io.write(", int")
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s", paramclass.name))
          break
        end
      end
    end
    if meth.params[2].tipo == "number" then
      io.write(", int")
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[2].tipo then
          io.write(string.format(", struct %s*", paramclass.name))
          break
        end
      end
    end
  elseif #meth.params == 3 then
    if meth.params[1].tipo == "number" then
      io.write(", int")
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[1].tipo then
          io.write(string.format(", struct %s*", paramclass.name))
          break
        end
      end
    end
    if meth.params[2].tipo == "number" then
      io.write(", int")
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[2].tipo then
          io.write(string.format(", struct %s", paramclass.name))
          break
        end
      end
    end
    if meth.params[3].tipo == "number" then
      io.write(", int")
    else
      for _, paramclass in ipairs(program.classes) do
        if paramclass.name == meth.params[3].tipo then
          io.write(string.format(", struct %s*", paramclass.name))
          break
        end
      end
    end
  end -- ipairs(class.methods)
  io.write(");\n")
end

return methods
