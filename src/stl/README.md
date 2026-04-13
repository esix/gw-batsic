# src/stl — Standard Data Structures

Generic data structures for use across the project. Inspired by C++ STL, adapted for batch.

All structures store data as space-separated strings in named environment variables. Operations take the **variable name** (not value) as the first argument.

## vec.bat — Vector (ordered list)

```batch
set "v="
call vec push v Apple         &:: v = "Apple"
call vec push v Banana        &:: v = "Apple Banana"
call vec push v Cherry        &:: v = "Apple Banana Cherry"

call vec front v __           &:: __ = "Apple"
call vec shift v              &:: v = "Banana Cherry"
call vec size v __            &:: __ = "2"
call vec includes v Banana    &:: errorlevel 0 (found)
call vec includes v Mango     &:: errorlevel 1 (not found)
call vec push_uniq v Banana   &:: errorlevel 1 (already exists, no change)
call vec clear v              &:: v = ""
```

| Method | Args | Returns | Description |
|--------|------|---------|-------------|
| `push` | name val | | Append value |
| `front` | name ret | `ret` = first element | Peek first (no remove) |
| `shift` | name | | Remove first element |
| `includes` | name val | errorlevel 0/1 | Check membership |
| `push_uniq` | name val | errorlevel 0=added, 1=dup | Append if not present |
| `size` | name ret | `ret` = count | Element count |
| `clear` | name | | Empty the vector |

## set.bat — Set (unordered, unique elements)

```batch
set "s="
call set add s X              &:: s = "X"
call set add s Y              &:: s = "X Y"
call set add s X              &:: s = "X Y" (no dup, errorlevel 1)

call set has s X              &:: errorlevel 0 (found)
call set has s Z              &:: errorlevel 1 (not found)
call set remove s X           &:: s = "Y"
call set size s __            &:: __ = "1"

set "a=A B C"
set "b=B C D"
call set union a b r          &:: r = "A B C D"
call set intersect a b r      &:: r = "B C"
call set diff a b r           &:: r = "A"
call set equal a b            &:: errorlevel 1 (not equal)
```

| Method | Args | Returns | Description |
|--------|------|---------|-------------|
| `add` | name val | errorlevel 0=added, 1=dup | Add element |
| `has` | name val | errorlevel 0/1 | Check membership |
| `remove` | name val | errorlevel 0=removed, 1=not found | Remove element |
| `size` | name ret | `ret` = count | Element count |
| `clear` | name | | Empty the set |
| `union` | a b dest | `dest` = a ∪ b | Set union |
| `intersect` | a b dest | `dest` = a ∩ b | Set intersection |
| `diff` | a b dest | `dest` = a \ b | Set difference |
| `equal` | a b | errorlevel 0/1 | Same elements? |

## iter.bat — Iterator utilities

```batch
call iter range 0 5 __        &:: __ = "0 1 2 3 4"
for %%i in (%__%) do echo %%i
```

| Method | Args | Returns | Description |
|--------|------|---------|-------------|
| `range` | from to ret | `ret` = "from from+1 ... to-1" | Integer range (exclusive end) |
