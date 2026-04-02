from std.reflection import get_type_name, struct_field_count, struct_field_names, struct_field_types
from std.builtin.rebind import downcast
from std.sys import stdout
from std.sys.intrinsics import _type_is_eq
from std.memory import ArcPointer

struct JSONSchema(Movable, JSONEncodable):
    var type: String
    var title: Optional[String]
    var description: Optional[String]
    var items: ArcPointer[Optional[JSONSchema]]
    var properties: Dict[String, ArcPointer[JSONSchema]]
    var required: Optional[List[String]]
    var `x-order`: Optional[List[String]]

    def __init__(out self, *, type: String, title: Optional[String] = None, description: Optional[String] = None,
      var items: ArcPointer[Optional[JSONSchema]] = ArcPointer(Optional[JSONSchema]()),
      var properties: Dict[String, ArcPointer[JSONSchema]] = {},
      var required: Optional[List[String]] = None, var `x-order`: Optional[List[String]] = None):
        self.type = type
        self.title = title
        self.description = description
        self.items = items^
        self.properties = properties^
        self.required = required^
        self.`x-order` = `x-order`^

    def should_write_field(self, field: String) -> Bool:
        if field == "properties":
            return len(self.properties) > 0
        return True

trait JSONSchemaInferrible:
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        comptime type_name = get_type_name[Self]()
        var properties = Dict[String, ArcPointer[JSONSchema]]()
        var required = List[String]()
        var x_order = List[String]()
        comptime field_count = struct_field_count[Self]()
        comptime field_names = struct_field_names[Self]()
        comptime field_types = struct_field_types[Self]()
        comptime descs = Self.field_descriptions()
        comptime for idx in range(field_count):
            comptime field_name = field_names[idx]
            comptime field_type = field_types[idx]
            var schema = downcast[field_type, JSONSchemaInferrible].inferred_json_schema()
            comptime desc = descs.get(field_name)
            comptime if desc:
                schema.description = desc.value()
            properties[field_name] = ArcPointer(schema^)
            if downcast[field_type, JSONSchemaInferrible].is_required():
                required.append(field_name)
            x_order.append(field_name)
        return JSONSchema(type="object", title=String(type_name), properties=properties^, required=required^, `x-order`=x_order^)

    @staticmethod
    def is_required() -> Bool:
        return True
    
    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension Int(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        return JSONSchema(type="integer")
    
    @staticmethod
    def is_required() -> Bool:
        return True

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension Bool(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        return JSONSchema(type="boolean")
        
    @staticmethod
    def is_required() -> Bool:
        return True

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension SIMD(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        comptime assert size == 1 and Self.dtype.is_floating_point()
        return JSONSchema(type="number")
        
    @staticmethod
    def is_required() -> Bool:
        return True

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension String(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        return JSONSchema(type="string")

    @staticmethod
    def is_required() -> Bool:
        return True

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension Optional(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        return downcast[Self.T, JSONSchemaInferrible].inferred_json_schema()

    @staticmethod
    def is_required() -> Bool:
        return False

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

__extension List(JSONSchemaInferrible):
    @staticmethod
    def inferred_json_schema() -> JSONSchema:
        var item_schema = downcast[Self.T, JSONSchemaInferrible].inferred_json_schema()
        return JSONSchema(type="array", items=ArcPointer(Optional(item_schema^)))

    @staticmethod
    def is_required() -> Bool:
        return True

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {}

@fieldwise_init
struct Person(Movable, Writable, JSONEncodable, JSONSchemaInferrible):
    var name: String
    var age: Int
    var height: Float64
    var alive: Bool
    var addresses: List[String]
    var pet: Optional[String]

    @staticmethod
    def field_descriptions() -> Dict[String, String]:
        return {"name": "The person's name."}

trait JSONEncodable:
    def write_json(self, fd: FileDescriptor):
        comptime field_count = struct_field_count[Self]()
        comptime field_names = struct_field_names[Self]()
        print("{", end="", file=fd)
        var first = True
        comptime for idx in range(field_count):
            ref value = trait_downcast[JSONEncodable](__struct_field_ref(idx, self))
            if value.is_omitted():
                continue
            comptime field_name = field_names[idx]
            if self.should_write_field(field_name):
                if first:
                    first = False
                else:
                    print(",", end="", file=fd)
                print("\"", field_name, "\":", sep="", end="", file=fd)
                value.write_json(fd)
        print("}", end="", file=fd)
    
    def is_omitted(self) -> Bool:
        return False
    
    def should_write_field(self, field: String) -> Bool:
        return True
        
__extension Int(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        print(self, end="", file=fd)

    def is_omitted(self) -> Bool:
        return False
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension Bool(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        print("true" if self else "false", end="", file=fd)

    def is_omitted(self) -> Bool:
        return False
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension SIMD(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        comptime assert size == 1 and Self.dtype.is_floating_point()
        print(self, end="", file=fd)

    def is_omitted(self) -> Bool:
        return False
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension String(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        print("\"", end="", file=fd)
        print(self, end="", file=fd)
        print("\"", end="", file=fd)

    def is_omitted(self) -> Bool:
        return False
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension Optional(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        if self:
            trait_downcast[JSONEncodable](self.value()).write_json(fd)
        else:
            print("null", end="", file=fd)

    def is_omitted(self) -> Bool:
        return not self
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension ArcPointer(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        trait_downcast[JSONEncodable](self[]).write_json(fd)

    def is_omitted(self) -> Bool:
        return trait_downcast[JSONEncodable](self[]).is_omitted()
        
    def should_write_field(self, field: String) -> Bool:
        return True

__extension List(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        print("[", end="", file=fd)
        var first = True
        for el in self:
            if first:
                first = False
            else:
                print(",", end="", file=fd)
            trait_downcast[JSONEncodable](el).write_json(fd)
        print("]", end="", file=fd)

    def is_omitted(self) -> Bool:
        return False

    def should_write_field(self, field: String) -> Bool:
        return True

__extension Dict(JSONEncodable):
    def write_json(self, fd: FileDescriptor):
        comptime assert _type_is_eq[Self.K, String]()
        print("{", end="", file=fd)
        var first = True
        for item in self.items():
            if first:
                first = False
            else:
                print(",", end="", file=fd)
            trait_downcast[JSONEncodable](item.key).write_json(fd)
            print(":", end="", file=fd)
            trait_downcast[JSONEncodable](item.value).write_json(fd)
        print("}", end="", file=fd)

    def is_omitted(self) -> Bool:
        return False

    def should_write_field(self, field: String) -> Bool:
        return True

