---
marp: true
theme: common
size: 16:9
paginate: true
---

<!--
_class: top
footer: 篠晃喜
-->

X.1 inc.
as const satisfies について

---

<!--
class: body
footer: X.1 inc.
-->

# 1. 概要

**1.2. TypeScript のメリット**

**1.3. as const satisfies とは**

---

# 1.1. TypeScript のメリット

TypeScript は JavaScript に静的型を追加した言語で、
コンパイルエラーを検出することで JavaScript 開発をさらに快適・効率的にしてくれるものです。

型システムを備えている言語は、多かれ少なかれ何らかの形で`型推論`を備えています。
大ざっぱに言えば、これは型を明示的に書かなくてもコンパイラがいい感じに型を推測して理解してくれる機能です。

今回は TypeScript のメリットである`型推論`をより効果的に使う方法の説明になります。

---

# 1.2. as const satisfies とは

TypeScript 4.9 から、satisfies operator が使えるようになりました。（2022/11〜）
従来の as const と組み合わせ、型チェックと widening 防止を同時に行えます。

satisfies とは何か？ as const とは何か？
2 つを組合わせると、どのようなメリットがあるのか？ について、
実際のコードと共に紹介します。

<!--
スライドコメント
-->

---

# 2.as const

**2.1. as const とは**

**2.2. 型拡大 （widening） とは**

**2.3. import・export での widening**

**2.4. widening を as const で防ぐ**

---

# 2.1. as const とは

`as const` とは、次の効果があります。

- 文字列・数値・真偽値などのリテラル型を **widening** しない
- オブジェクト内のすべてのプロパティが **readonly** になる
- 配列リテラルの推論結果が**タプル型**になる

<!--
スライドコメント
-->

---

# 2.2. 型拡大 （widening） とは

次の `myFavoriteColor` は、リテラル型の「`"blue"`型」に推論されます。

```ts
const myFavoriteColor = "blue";
// "blue"型
```

---

`let` で変数を宣言すると、`myFavoriteColor2` の型は、リテラル型の `"blue"`型ではなく、より広い `string` になります。

```ts
let myFavoriteColor2 = "blue";
// string型
```

このように、より型が大きくなる挙動のことを widening と呼びます。

<!--
スライドコメント
-->

---

```ts
const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
};

// 推論結果
// {
//  red: string,
//  green: number[]
//  blue: string
//}
```

オブジェクトの場合、各プロパティが widening し、
`{ red: string, green: number[], blue: string }` と推論されます。

`{ red: "#ff0000", green: [0, 255, 0], blue: "#0000ff" }` とは推論されません。

オブジェクトの各プロパティが widening するのは、各プロパティが書き換え可能なことが原因です。

<!-- もちろん、配列も widening します。
次の例では、 `green` は `number[]` 型になります。

`[number, number, number]` や `[0, 255, 0]` とは推論されません。

```ts
const myArray = [0, 255, 0];
// 推論結果はnumber[]
``` -->

---

# 2.3. import・export での widening

1 つのモジュール内での話あれば気をつければ済む話でしょう。
問題は、import・export した際です。

他の開発者が `myObject` を import してロジックを書いたとします。

```ts
export const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
};
```

<!--
スライドコメント
-->

---

```ts
import { colorList } from "./colorList";

// "#ff0000"型ではなく、string型
const colorRed = colorList.red;
```

`colorList.red`は `"#ff0000"` ではなく、
`string` 型になってしまいましたが、使用者側は気づきづらい、、、

---

`colorList.red`が何なのか知るには下記 ① or ② をする必要がある。

① 実行する
② 定義されてるところを見に行く

同じファイル内なら良いが、大規模プロジェクトで
export されたオブジェクトの場合は、追うのが大変だし、中身が分からないオブジェクトは使いづらい。

<!-- 実行した場合は`colorList.red`は"`"#ff0000"`で出てくる。 -->

---

# 2.4. widening を as const で防ぐ

widening は、`as const` で防げます。

オブジェクトにおける widening の抑制例は次のとおりです。

▼ export 側

```ts
export const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
} as const;
```

---

▼ import 側

```ts
import { colorList } from "./colorList";

// "#ff0000"型
const colorRed = colorList.red;
```

文字列や数値といったプリミティブ型も、 `as const` で widening を防げます。

---

# 3. satisfies

**3.1. satisfies とは**

**3.2. satisfies を使うと、型推論結果が保持される**

**3.3. 型注釈では型推論結果が失われる**

---

# 3.1. satisfies とは

`satisfies` とは、TypeScript 4.9 で導入された新しい演算子です。

```ts
const white = "白" satisfies string;

// "白" が string型 にマッチするかどうか？ OK
```

```ts
const white = [255, 255, 255] satisfies string;

// [255, 255, 255] が string型 にマッチするかどうか？ NG
```

---

次のように定義したとき、`colorList` オブジェクトが、 `ColorList` 型にマッチするかどうかをチェックできます。

```ts
type ColorList = {
  [key in "red" | "blue" | "green"]: unknown;
};

const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
} satisfies ColorList;
```

---

`ColorList` 型の `[key in "red" | "blue" | "green"]` とは、
オブジェクトのキーが `red` か `blue` か `green` のいずれかという意味です。

オブジェクトの値が `unknown` なので、次のことを表現した型になります。

- オブジェクトのキーが `red` か `blue` か `green` のいずれか
- オブジェクトの値は何でもいい

---

`colorList` オブジェクトが `ColorList` 型にマッチしない場合、エラーが起こります。

▼ `yellow` キーが `ColorList` 型にマッチしない旨のエラー

```ts
const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  // ❌エラー
  yellow: "#0000ff",
} satisfies ColorList;
```

---

# 3.2. `satisfies` を使うと、型推論結果が保持される

`satisfies` の特徴は、**型チェックが行われつつも、型推論結果が保持されることです**。
「satisfies」（サティスファイズ）は「（条件などを）満たす、確信させる」といった意味があります。

<!--
少しややこしい、、ので詳しく説明していきます
-->

---

次の `colorList` オブジェクトにおいて、`green` は `ColorList` の型の一部であることがチェックされ、かつ `number[]` 型と推論されます。
配列なので、配列用メソッド `map()` が使えます。

▼ `green` は配列なので、配列用のメソッドが使える

```ts
const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
} satisfies ColorList;

// 配列のメソッドを実行
colorList.green.map((value) => value * 2);
```

---

## Q. 型注釈と何が違うの？ 🤔

## A. 推論結果を保持するかどうか

---

# 3.3. 型注釈では型推論結果が失われる

`satisfies ColorList` は、 `colorList` オブジェクトに型注釈 `: ColorList` をつけることと、何が違うのでしょうか？
動作の違いを確認してみましょう。

```ts
const colorList: ColorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
};
```

<!--
型注釈で良いのでは？？？
僕もそう思いましたが挙動に違いがあり、型注釈より優れている点があります
-->

---

この場合も `colorList` オブジェクトが `ColorList` 型にマッチしない場合、エラーが起こります。

```ts
const colorList: ColorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  // ❌エラー
  yellow: "#0000ff",
};
```

<!--
ここまではsatisfiesも型注釈も挙動としては一見、同じです
-->

---

**`satisfies` と異なるのは推論結果です**。

型注釈を設定する場合、当然ですが型の推論結果は失われ、
`colorList` オブジェクトの型情報は `ColorList` 型になります。

---

そのため `green` プロパティは `unknown` となり配列用の関数が使えません。

開発者が `green` が配列であることを明らかに分かっている場合でも、、

```ts
const colorList: ColorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  blue: "#0000ff",
};

// ❌エラー
// green は unknown なので、 map() は使えない
colorList.green.map((value) => value * 2);
```

「型のチェックをしたいが、推論結果は保持したい」というケースには、型注釈よりも `satisfies` が有効です。

---

### 補足

`type ColorList = { red: string,  green: [number, number, number],  blue: string };`
と表現すれば `green` で正しく `map` が使えます。

しかし、`purple` や `pink` など、新しくキーを追加するたびに
それに対応する値の型を追加する必要があります。

「オブジェクトの値はなんでもいいので、キーの種類だけを制限したい」という
当初の目的からは外れてしまいますし、大して詳細な情報を持たない型注釈と、
詳細な情報を持つ値を **二重管理** になってしまう。`

<!-- 二重管理したくない、どっちか反映忘れとかの可能性も出てくる為。具体例は後で紹介します。 -->

---
### `satisfies` の具体例
下記の `as` （型アサーション）を `satisfies` を使って、置き換える

```ts
type Colors = "red" | "green" | "blue";
type RGB = [red: number, green: number, blue: number];

const palette: Record< Colors, string | RGB> = {
  red: [255, 0, 0],
  green: "#00ff00",
  blue: [0, 0, 255],
}

const red = palette.red as RGB

const redComponent = red.map((v) => v * 2);

const green = palette.green as string

const greenNormalized = green.toUpperCase();
```

---

`satisfies` に置き換えることで
`as（型アサーション）` を使わずにTypescriptのコンパイラーの型推論を使って、
型安全に値を使うことが出来る。
```ts
type Colors = "red" | "green" | "blue";
type RGB = [red: number, green: number, blue: number];

const palette = {
  red: [255, 0, 0],
  green: "#00ff00",
  blue: [0, 0, 255],
} satisfies Record< Colors, string | RGB>

const redComponent = palette.red.map((v) => v * 2);

const greenNormalized = palette.green.toUpperCase();
```

---

# 4. satisfies と as const

**4.1. satisfies と as const を組み合わせる**

**4.2. satisfies なし、 as const なしの場合**

**4.3. satisfies なし、 as const ありの場合**

**4.4. satisfies あり、 as const なしの場合**

**4.5. satisfies あり、 as const ありの場合**

---

# 4.1. satisfies と as const を組み合わせる

`satisfies` と `as const` を組み合わせると、2 つのメリットを組み合わせられます。

1. `satisfies`: 型がマッチするかどうかをチェックできる
2. `as const`: 値が widening しない

<!--
今回のメインです。
-->

---

今回は `MyOption` を使って考えてみましょう。

```ts
type MyOption = {
  foo: string;
  bar: number;
  baz: {
    qux: number;
  };
};
```

`MyOption` 型を満たす `myOption` オブジェクトを作って、 export したいとします。

```ts
export const myOption = {
  foo: "foo",
  bar: 2,
  baz: {
    qux: 3,
  },
};
```

---

# 4.2. `satisfies` なし、 `as const` なしの場合

`myOption` は何一つ型安全ではありません。
大規模なプロジェクトになるほど、`myOption` は闇に葬られます。

```ts
export const myOption = {
  foo: "foo",
  bar: 2,
  baz: {
    qux: 3,
  },
};
```

<!--
実行したら分かるので、
reactのjsxで表示する時
-->

<!-- ---

▼ `as const` を使ってないデメリット
Reactの `jsx` にそのまま流し込んで表示させる場合に
何が表示されるのか実行するまで分からない。

下記のように、意図してない値になっている可能性もある。

```tsx
const colorRed = colorList.red = "#fff";

return (
  <>
    {colorRed}
  </>
)
```

---

▼ `satisfies` を使ってないデメリット

当たり前ですが、オブジェクトに新しいプロパティと値を設定できる。

```ts
export const colorList = {
  red: "#ff0000",
  green: [0, 255, 0],
  // blue消して、yellow追加できる
  yellow: "sampleColor",
};
```

<!-- リファクタリング際など？意図していない値を消してしまったり
追加してしまったりする可能性が出てくる。

型推論を活かしながら型を注釈できる機能
-->

---

# 4.3. `satisfies` なし、 `as const` ありの場合

widening は防げますが、型チェックができなくなります。

```ts
export const myOption = {
  foo: "foo",
  // 型エラーにならない
  bar: "HELLO",
  baz: {
    qux: 3,
  },
} as const;
```

<!--
特に指定はされてないので、エラーにはならない、プロパティをプラスできる
-->

---

▼ `myOption` の推論結果

```
{
  foo: "foo",
  bar: "HELLO",
  baz: {
    qux: 3,
  },
}
```

---

# 4.4. `satisfies` あり、 `as const` なしの場合

型のチェックはできます。

```ts
export const myOption = {
  foo: "foo",
  // 型エラーになる
  bar: "HELLO",
  baz: {
    qux: 3,
  },
} satisfies MyOption;
```

<!-- greenは、numberの配列だけど、stringで定義している為 -->

---

しかし、 `myOption` オブジェクトは widening してしまいます。

▼ `myOption` オブジェクトの推論結果

```ts
{
  foo: string,
  bar: number,
  baz: {
    qux: number,
  },
}
```

他の開発者が `myOption` オブジェクトを使う時、型が widening していることに気づきづらいです。

<!--
スライドコメント
-->

---

# 4.5. `satisfies` あり、 `as const` ありの場合

型チェックが可能であり、かつ widening も防げます 💐

```ts
export const myOption = {
  foo: "foo",
  // 型エラーになる
  bar: "HELLO",
  baz: {
    qux: 3,
  },
} as const satisfies MyOption;
```

---

▼ `myOption` を正しく修正する

```ts
export const myOption = {
  foo: "foo",
  bar: 2,
  baz: {
    qux: 3,
  },
} as const satisfies MyOption;
```

---

▼ `myOption` の推論結果

```ts
{
  foo: "foo",
  bar: 2,
  baz: {
    qux: 3,
  },
}
```

<!-- `as const` ・・・ 使う側が便利 `satisfies` ・・・ 定義する側で便利 -->

---

# 5. オブジェクト以外での活用

**5.1. 配列と as const satisfies**

---

# 5.1. 配列と `as const satisfies`

配列を使う際も、`as const satisfies` は便利です。

たとえば、次の `myArray` を `string[]` で型注釈したとき、
`typeof myArray[number]` の型（任意のインデックスの要素の型）は
`string` にしかなりません。

```ts
const myArray: readonly string[] = ["りんご", "みかん", "ぶどう"];
type MyElement = typeof myArray[number];
// string型
```

<!--
スライドコメント
-->

---

`as const satisfies` を使うと、`typeof myArray[number]` の型（任意のインデックスの要素の型）は `"りんご" | "みかん" | "ぶどう"` になります。

もちろん、`myArray` に文字列以外の要素を追加するとエラーになります。

```ts
const myArray = ["りんご", "みかん", "ぶどう"] as const satisfies readonly string[];
type MyElement = typeof myArray[number];
// "りんご" | "みかん" | "ぶどう" 型
```

---

# 6. as const satisfies の活用例

**6.1. 元号のリスト**

**6.2. URL のリスト**

**6.3. ステータスのリスト**

---

# 6.1. 元号のリスト

```ts
export const eraNames = ["昭和", "平成", "令和"] as const satisfies readonly string[];
```

<!--
後々、他の開発者が使う際

eraNamesに年号をプラスして定義したい時、number型（2023）を入れたらエラーになる

importして使う際に、as constでwideningを防ぐことが出来るので、型推論によって、値に何が入っているのか、すぐ分かる

eraNames[1]
-->

---

# 6.2. URL のリスト

```ts
export const urlList = {
  apple: "https://www.apple.com/jp/",
  google: "https://www.google.com/",
  yahoo: "https://www.yahoo.co.jp/",
} as const satisfies {
  // 値は https:// で始まるURLに限定する
  [key: string]: `https://${string}`;
};
```

<!--
すべてを二重管理したくないので、良い使い例だと思う。
-->

---

# 6.3. カラーパレットのオブジェクト

```ts
type Colors = "red" | "green" | "blue";
type RGB = Readonly<[red: number, green: number, blue: number]>;
```

```ts
const palette = {
  red: [255, 0, 0],
  green: "#00ff00",
  bule: [0, 0, 255],
  // タイポに気づく
} as const satisfies Record<Colors, string | RGB>;

// 配列とstringのどちらのメソッドも型推論が働いてくれるので機能する!
const redComponent = palette.red.map((v) => v * 2);
const greenNormalized = palette.green.toUpperCase();
```

---

### まとめ

`as const satisfies` で
**widening 防止**と
**型推論結果の保持**ができる。

オブジェクトか配列を`export`する際には
使う人のことを考えて
`as const satisfies` しておくのが良い:tada:

<!-- 型の拡大について意識できるようになるので、
よりtypescriptの機能を使えるようになったり、想定してない値を明確でない値を使ってしまうことが減る -->

---

参考文献

[TypeScript 4.9 の as const satisfies が便利](https://zenn.dev/moneyforward/articles/typescript-as-const-satisfies)

[Documentation - TypeScript 4.9](https://www.typescriptlang.org/docs/handbook/release-notes/typescript-4-9.html)

[TypeScript における型の集合性と階層性](https://zenn.dev/estra/articles/typescript-type-set-hierarchy)

[データ型とリテラル · JavaScript Primer #jsprimer](https://jsprimer.net/basic/data-type/)
