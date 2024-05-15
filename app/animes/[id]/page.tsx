import { createClient } from "@/utils/supabase/server";
import { redirect } from "next/navigation";
import { Tables } from "@/types/supabase";
import Display from "./display";

export default async function Page({ params: { id } }: { params: { id: string } }) {
    const supabase = createClient();

    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
        return redirect("/login");
    }

    const isModerator = await supabase.rpc("is_in_role", "moderator").returns<number>()

    const { data, error } = await supabase.from("animes")
        .select()
        .eq("id", `${id}`)
        .returns<Tables<"animes">[]>();

    if (!data?.[0]) {
        return redirect("/animes");
    }

    return (
        <Display item={data[0]} />
    )
}