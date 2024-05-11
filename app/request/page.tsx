import { createClient } from "@/utils/supabase/server";
import { redirect } from "next/navigation";
import { RequestForm } from "./form";

export default async function RequestPage() {
    const supabase = createClient();

    const {
        data: { user },
    } = await supabase.auth.getUser();

    if (!user) {
        return redirect("/login");
    }

    return (
        <RequestForm />
    )
}